require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const path = require('path');

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const pool = mysql.createPool({
  host: process.env.DB_HOST, user: process.env.DB_USER,
  password: process.env.DB_PASSWORD, database: process.env.DB_NAME,
  waitForConnections: true, connectionLimit: 10, decimalNumbers: true
});
const wrap = fn => (req, res) => fn(req, res).catch(e => { console.error(e); res.status(500).json({ error: e.message }); });

// ---------- Catálogo ----------
app.get('/api/recipes', wrap(async (_, res) => {
  const [rows] = await pool.query(
    `SELECT r.id, r.name, r.price, ri.qty, i.name AS ingredient
     FROM recipes r JOIN recipe_ingredients ri ON ri.recipe_id=r.id JOIN ingredients i ON i.id=ri.ingredient_id`);
  const out = {};
  rows.forEach(r => { (out[r.name] ||= { id: r.id, price: r.price, ingredients: [] }).ingredients.push([r.ingredient, r.qty]); });
  res.json(out);
}));

app.get('/api/inventory', wrap(async (_, res) => {
  const [rows] = await pool.query('SELECT * FROM ingredients ORDER BY id');
  res.json(rows);
}));

app.get('/api/movements', wrap(async (_, res) => {
  const [rows] = await pool.query(
    `SELECT m.*, i.name AS ingredient FROM movements m JOIN ingredients i ON i.id=m.ingredient_id
     ORDER BY m.id DESC LIMIT 100`);
  res.json(rows);
}));

// ---------- Pedidos ----------
async function loadOrders(deleted) {
  const [orders] = await pool.query(
    `SELECT * FROM orders WHERE deleted_at IS ${deleted ? 'NOT NULL' : 'NULL'} ORDER BY id DESC`);
  if (!orders.length) return [];
  const [items] = await pool.query(
    `SELECT oi.order_id, r.name, oi.qty FROM order_items oi JOIN recipes r ON r.id=oi.recipe_id
     WHERE oi.order_id IN (?)`, [orders.map(o => o.id)]);
  return orders.map(o => ({ ...o, code: `TR-${o.id}`, items: items.filter(i => i.order_id === o.id) }));
}
app.get('/api/orders', wrap(async (_, res) => res.json(await loadOrders(false))));
app.get('/api/orders/deleted', wrap(async (_, res) => res.json(await loadOrders(true))));

app.post('/api/orders', wrap(async (req, res) => {
  const { customer, items, notes = '', priority = 'Media' } = req.body;
  if (!customer || !Array.isArray(items) || !items.length)
    return res.status(400).json({ error: 'Falta cliente o platillos' });
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [r] = await conn.query('INSERT INTO orders (customer,notes,priority) VALUES (?,?,?)', [customer, notes, priority]);
    for (const it of items) {
      await conn.query(
        'INSERT INTO order_items (order_id,recipe_id,qty) SELECT ?, id, ? FROM recipes WHERE name=?',
        [r.insertId, it.qty, it.name]);
    }
    await conn.commit();
    res.status(201).json({ id: r.insertId, code: `TR-${r.insertId}` });
  } catch (e) { await conn.rollback(); throw e; } finally { conn.release(); }
}));

// Cambiar estado (descuenta inventario UNA sola vez al pasar a "En preparación")
app.patch('/api/orders/:id/status', wrap(async (req, res) => {
  const { status } = req.body, id = +req.params.id;
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [[o]] = await conn.query('SELECT * FROM orders WHERE id=? FOR UPDATE', [id]);
    if (!o) { await conn.rollback(); return res.status(404).json({ error: 'No existe' }); }
    if (status === 'En preparación' && !o.discounted) {
      const [needs] = await conn.query(
        `SELECT ri.ingredient_id, SUM(ri.qty*oi.qty) AS need
         FROM order_items oi JOIN recipe_ingredients ri ON ri.recipe_id=oi.recipe_id
         WHERE oi.order_id=? GROUP BY ri.ingredient_id`, [id]);
      for (const n of needs) {
        const [[ing]] = await conn.query('SELECT quantity FROM ingredients WHERE id=? FOR UPDATE', [n.ingredient_id]);
        const after = Math.max(0, ing.quantity - n.need);
        await conn.query('UPDATE ingredients SET quantity=? WHERE id=?', [after, n.ingredient_id]);
        await conn.query(
          `INSERT INTO movements (type,ingredient_id,order_id,amount,before_qty,after_qty)
           VALUES ('Consumo por pedido',?,?,?,?,?)`, [n.ingredient_id, id, n.need, ing.quantity, after]);
      }
      await conn.query('UPDATE orders SET discounted=1 WHERE id=?', [id]);
    }
    await conn.query('UPDATE orders SET status=? WHERE id=?', [status, id]);
    await conn.commit();
    res.json({ ok: true });
  } catch (e) { await conn.rollback(); throw e; } finally { conn.release(); }
}));

// Eliminar (soft) solo si está Entregado / restaurar / eliminar definitivo
app.patch('/api/orders/:id/delete', wrap(async (req, res) => {
  const [r] = await pool.query("UPDATE orders SET deleted_at=NOW() WHERE id=? AND status='Entregado'", [req.params.id]);
  res.status(r.affectedRows ? 200 : 400).json({ ok: !!r.affectedRows });
}));
app.patch('/api/orders/:id/restore', wrap(async (req, res) => {
  await pool.query('UPDATE orders SET deleted_at=NULL WHERE id=?', [req.params.id]);
  res.json({ ok: true });
}));
app.delete('/api/orders/:id', wrap(async (req, res) => {
  await pool.query('DELETE FROM orders WHERE id=? AND deleted_at IS NOT NULL', [req.params.id]);
  res.json({ ok: true });
}));

// ---------- Movimientos manuales de inventario ----------
app.post('/api/inventory/:id/movement', wrap(async (req, res) => {
  const { type, amount, reason, supplier, cost, note } = req.body, id = +req.params.id;
  if (!['Entrada', 'Salida manual'].includes(type) || !(amount > 0))
    return res.status(400).json({ error: 'Datos inválidos' });
  if (type === 'Salida manual' && !reason) return res.status(400).json({ error: 'Motivo obligatorio' });
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [[ing]] = await conn.query('SELECT quantity FROM ingredients WHERE id=? FOR UPDATE', [id]);
    if (!ing) { await conn.rollback(); return res.status(404).json({ error: 'No existe' }); }
    if (type === 'Salida manual' && amount > ing.quantity) {
      await conn.rollback();
      return res.status(400).json({ error: `Stock insuficiente: solo hay ${ing.quantity}` });
    }
    const after = type === 'Entrada' ? ing.quantity + amount : ing.quantity - amount;
    await conn.query('UPDATE ingredients SET quantity=? WHERE id=?', [after, id]);
    await conn.query(
      `INSERT INTO movements (type,ingredient_id,amount,before_qty,after_qty,reason,supplier,cost,note)
       VALUES (?,?,?,?,?,?,?,?,?)`,
      [type, id, amount, ing.quantity, after, reason || null, supplier || null, cost || null, note || null]);
    await conn.commit();
    res.json({ ok: true, quantity: after });
  } catch (e) { await conn.rollback(); throw e; } finally { conn.release(); }
}));

app.listen(process.env.PORT || 3000, () => console.log(`ChefMaster en http://localhost:${process.env.PORT || 3000}`));

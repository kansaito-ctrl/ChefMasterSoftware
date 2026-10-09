require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const dbConfig = {
  host: process.env.DB_HOST, port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER, password: process.env.DB_PASSWORD, database: process.env.DB_NAME,
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined
};
const pool = mysql.createPool({ ...dbConfig, waitForConnections: true, connectionLimit: 10, decimalNumbers: true });
const wrap = fn => (req, res) => fn(req, res).catch(e => { console.error(e); res.status(500).json({ error: e.message }); });

// ================= Acceso: administración y cocina =================
const SECRET = () => process.env.ADMIN_PASSWORD || '';
const sign = s => crypto.createHmac('sha256', SECRET()).update(s).digest('hex');
const hash = s => crypto.createHash('sha256').update(String(s)).digest();
const same = (a, b) => crypto.timingSafeEqual(hash(a), hash(b));

app.post('/api/login', (req, res) => {
  const role = req.body.role === 'cocina' ? 'cocina' : 'admin';
  const pw = role === 'cocina' ? process.env.COCINA_PASSWORD : process.env.ADMIN_PASSWORD;
  if (!pw || !SECRET() || !same(req.body.password || '', pw))
    return res.status(401).json({ error: 'Contraseña incorrecta' });
  const body = `${Date.now() + 8 * 60 * 60 * 1000}.${role}`;
  res.json({ token: `${body}.${sign(body)}`, role });
});

function getRole(req) {
  const [exp, role, sig] = (req.headers.authorization || '').replace('Bearer ', '').split('.');
  try {
    if (SECRET() && sig && Number(exp) > Date.now() && same(sig, sign(`${exp}.${role}`))) return role;
  } catch (e) {}
  return null;
}

const match = (rules, req) => rules.some(([m, p]) => m === req.method && (p instanceof RegExp ? p.test(req.path) : p === req.path));
const PUBLICAS = [['POST', '/login'], ['GET', '/menu'], ['POST', '/orders']];            // clientes
const COCINA = [['GET', '/orders'], ['GET', '/recipes'], ['PATCH', /^\/orders\/\d+\/status$/]]; // cocina
app.use('/api', (req, res, next) => {
  if (match(PUBLICAS, req)) return next();
  const role = getRole(req);
  if (role === 'admin' || (role === 'cocina' && match(COCINA, req))) return next();
  res.status(role ? 403 : 401).json({ error: role ? 'Sin permiso' : 'No autorizado' });
});

// ================= Catálogo =================
app.get('/api/menu', wrap(async (_, res) => {          // público: lo que ve el cliente
  const [rows] = await pool.query(
    `SELECT r.id, r.name, r.price, r.category, r.description,
            GROUP_CONCAT(i.name ORDER BY ri.qty DESC SEPARATOR ', ') AS ingredients
     FROM recipes r
     LEFT JOIN recipe_ingredients ri ON ri.recipe_id = r.id
     LEFT JOIN ingredients i ON i.id = ri.ingredient_id
     WHERE r.active = 1 GROUP BY r.id ORDER BY r.id`);
  res.json(rows);
}));

app.get('/api/recipes', wrap(async (_, res) => {
  const [rows] = await pool.query(
    `SELECT r.id, r.name, r.price, r.category, r.description, r.active, ri.qty, i.name AS ingredient
     FROM recipes r JOIN recipe_ingredients ri ON ri.recipe_id = r.id JOIN ingredients i ON i.id = ri.ingredient_id`);
  const out = {};
  rows.forEach(r => {
    (out[r.name] ||= { id: r.id, price: r.price, category: r.category, description: r.description, active: !!r.active, ingredients: [] })
      .ingredients.push([r.ingredient, r.qty]);
  });
  res.json(out);
}));

// Añadir un platillo nuevo a la carta
app.post('/api/recipes', wrap(async (req, res) => {
  const { name, category, price, description = '', ingredients = [] } = req.body;
  if (!name || !category || !(price >= 0) || !Array.isArray(ingredients) || !ingredients.length)
    return res.status(400).json({ error: 'Faltan datos del platillo' });
  const names = ingredients.map(i => i.name);
  const [found] = await pool.query('SELECT name FROM ingredients WHERE name IN (?)', [names]);
  const missing = names.filter(n => !found.some(f => f.name === n));
  if (missing.length) return res.status(400).json({ error: `No existe en inventario: ${missing.join(', ')}` });
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [r] = await conn.query('INSERT INTO recipes (name,price,category,description) VALUES (?,?,?,?)',
      [String(name).trim(), price, category, description]);
    for (const i of ingredients)
      await conn.query('INSERT INTO recipe_ingredients (recipe_id,ingredient_id,qty) SELECT ?, id, ? FROM ingredients WHERE name=?',
        [r.insertId, i.qty, i.name]);
    await conn.commit();
    res.status(201).json({ id: r.insertId });
  } catch (e) {
    await conn.rollback();
    if (e.code === 'ER_DUP_ENTRY') return res.status(409).json({ error: 'Ya existe un platillo con ese nombre' });
    throw e;
  } finally { conn.release(); }
}));

// Cambiar precio o ocultar/mostrar un platillo
app.patch('/api/recipes/:id', wrap(async (req, res) => {
  const { price, active } = req.body;
  if (price !== undefined) await pool.query('UPDATE recipes SET price=? WHERE id=?', [price, req.params.id]);
  if (active !== undefined) await pool.query('UPDATE recipes SET active=? WHERE id=?', [active ? 1 : 0, req.params.id]);
  res.json({ ok: true });
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

// ================= Pedidos =================
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

const cleanItems = items => (Array.isArray(items) ? items : [])
  .map(i => ({ name: String(i.name || ''), qty: parseInt(i.qty, 10) }))
  .filter(i => i.name && i.qty > 0 && i.qty <= 50);

const ADD_ITEM = `INSERT INTO order_items (order_id,recipe_id,qty) SELECT ?, id, ? FROM recipes WHERE name=? AND active=1
                  ON DUPLICATE KEY UPDATE qty = order_items.qty + ?`;

app.post('/api/orders', wrap(async (req, res) => {   // lo usan administración y clientes
  const customer = String(req.body.customer || '').trim().slice(0, 80);
  const items = cleanItems(req.body.items);
  const notes = String(req.body.notes || '').slice(0, 300);
  const priority = ['Alta', 'Media', 'Baja'].includes(req.body.priority) ? req.body.priority : 'Media';
  if (!customer || !items.length) return res.status(400).json({ error: 'Falta cliente o platillos' });
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [r] = await conn.query('INSERT INTO orders (customer,notes,priority) VALUES (?,?,?)', [customer, notes, priority]);
    for (const it of items) {
      const [x] = await conn.query(ADD_ITEM, [r.insertId, it.qty, it.name, it.qty]);
      if (!x.affectedRows) { await conn.rollback(); return res.status(400).json({ error: `No existe el platillo: ${it.name}` }); }
    }
    await conn.commit();
    res.status(201).json({ id: r.insertId, code: `TR-${r.insertId}` });
  } catch (e) { await conn.rollback(); throw e; } finally { conn.release(); }
}));

// --- consumo de inventario ---
async function needsForOrder(conn, orderId) {
  const [rows] = await conn.query(
    `SELECT ri.ingredient_id, SUM(ri.qty*oi.qty) AS need
     FROM order_items oi JOIN recipe_ingredients ri ON ri.recipe_id=oi.recipe_id
     WHERE oi.order_id=? GROUP BY ri.ingredient_id`, [orderId]);
  return rows.map(r => ({ ingredient_id: r.ingredient_id, need: Number(r.need) }));
}
async function needsForItems(conn, items) {
  const map = {};
  for (const it of items) {
    const [rows] = await conn.query(
      `SELECT ri.ingredient_id, ri.qty*? AS need FROM recipe_ingredients ri
       JOIN recipes r ON r.id=ri.recipe_id WHERE r.name=?`, [it.qty, it.name]);
    rows.forEach(r => { map[r.ingredient_id] = (map[r.ingredient_id] || 0) + Number(r.need); });
  }
  return Object.entries(map).map(([id, need]) => ({ ingredient_id: +id, need }));
}
async function consume(conn, orderId, needs) {
  for (const n of needs) {
    const [[ing]] = await conn.query('SELECT quantity FROM ingredients WHERE id=? FOR UPDATE', [n.ingredient_id]);
    const after = Math.max(0, ing.quantity - n.need);
    await conn.query('UPDATE ingredients SET quantity=? WHERE id=?', [after, n.ingredient_id]);
    await conn.query(
      `INSERT INTO movements (type,ingredient_id,order_id,amount,before_qty,after_qty)
       VALUES ('Consumo por pedido',?,?,?,?,?)`, [n.ingredient_id, orderId, n.need, ing.quantity, after]);
  }
}

// Cambiar estado (descuenta inventario UNA sola vez al pasar a "En preparación")
app.patch('/api/orders/:id/status', wrap(async (req, res) => {
  const { status } = req.body, id = +req.params.id;
  if (!['Nuevo', 'En preparación', 'Listo', 'Entregado'].includes(status))
    return res.status(400).json({ error: 'Estado inválido' });
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [[o]] = await conn.query('SELECT * FROM orders WHERE id=? FOR UPDATE', [id]);
    if (!o) { await conn.rollback(); return res.status(404).json({ error: 'No existe' }); }
    if (status === 'En preparación' && !o.discounted) {
      await consume(conn, id, await needsForOrder(conn, id));
      await conn.query('UPDATE orders SET discounted=1 WHERE id=?', [id]);
    }
    await conn.query('UPDATE orders SET status=? WHERE id=?', [status, id]);
    await conn.commit();
    res.json({ ok: true });
  } catch (e) { await conn.rollback(); throw e; } finally { conn.release(); }
}));

// Agregar platillos a una mesa/pedido que ya existe
app.post('/api/orders/:id/items', wrap(async (req, res) => {
  const id = +req.params.id, items = cleanItems(req.body.items);
  if (!items.length) return res.status(400).json({ error: 'Elige al menos un platillo' });
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [[o]] = await conn.query('SELECT * FROM orders WHERE id=? AND deleted_at IS NULL FOR UPDATE', [id]);
    if (!o) { await conn.rollback(); return res.status(404).json({ error: 'No existe el pedido' }); }
    if (o.status === 'Entregado') { await conn.rollback(); return res.status(400).json({ error: 'El pedido ya fue entregado' }); }
    for (const it of items) {
      const [x] = await conn.query(ADD_ITEM, [id, it.qty, it.name, it.qty]);
      if (!x.affectedRows) { await conn.rollback(); return res.status(400).json({ error: `No existe el platillo: ${it.name}` }); }
    }
    if (o.discounted) await consume(conn, id, await needsForItems(conn, items));      // ya se estaba preparando
    if (o.status === 'Listo') await conn.query("UPDATE orders SET status='En preparación' WHERE id=?", [id]); // reabre la comanda
    await conn.commit();
    res.json({ ok: true });
  } catch (e) { await conn.rollback(); throw e; } finally { conn.release(); }
}));

// Eliminar (suave) solo si está Entregado / restaurar / eliminar definitivo
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

// ================= Movimientos manuales de inventario =================
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

// Reinicia la demo: ejecuta seed_demo.sql (solo administración + clave)
app.post('/api/reset', wrap(async (req, res) => {
  if (!process.env.RESET_KEY || req.body.key !== process.env.RESET_KEY)
    return res.status(403).json({ error: 'Clave incorrecta' });
     const sql = ['seed_demo.sql', 'seed_stock_menu.sql'].filter(f => fs.existsSync(path.join(__dirname, f)))
     .map(f => fs.readFileSync(path.join(__dirname, f), 'utf8')).join('\n');
  const conn = await mysql.createConnection({ ...dbConfig, multipleStatements: true });
  try { await conn.query(sql); } finally { await conn.end(); }
  res.json({ ok: true });
}));

app.listen(process.env.PORT || 3000, () => console.log(`ChefMaster en http://localhost:${process.env.PORT || 3000}`));
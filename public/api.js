
async function api(url, opt = {}) {
  const r = await fetch(url, {
    method: opt.method || 'GET',
    headers: { 'Content-Type': 'application/json' },
    body: opt.body ? JSON.stringify(opt.body) : undefined
  });
  const d = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(d.error || 'Error del servidor');
  return d;
}

async function loadAll() {
  const [rec, inv, ords, dels, movs] = await Promise.all([
    api('/api/recipes'), api('/api/inventory'), api('/api/orders'),
    api('/api/orders/deleted'), api('/api/movements')
  ]);
  const hora = d => new Date(d).toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' });
  const fecha = d => new Date(d).toLocaleString('es-MX', { dateStyle: 'short', timeStyle: 'short' });

  Object.keys(recipes).forEach(k => delete recipes[k]);
  Object.assign(recipes, rec);
  document.getElementById('new-product').innerHTML =
    Object.keys(recipes).map(x => `<option value="${x}">${x}</option>`).join('');

  const consumo = {};
  movs.filter(m => m.order_id).forEach(m => { consumo[m.order_id] = hora(m.created_at); });
  const mapOrder = o => ({
    id: o.code, dbId: o.id, customer: o.customer,
    items: o.items.map(i => ({ name: i.name, qty: i.qty })),
    notes: o.notes || '', priority: o.priority, status: o.status,
    discounted: !!o.discounted, created: hora(o.created_at),
    consumedAt: consumo[o.id] || '',
    deletedAt: o.deleted_at ? new Date(o.deleted_at).toLocaleString('es-MX') : ''
  });

  inventory = inv;
  orders = ords.map(mapOrder);
  deletedOrders = dels.map(mapOrder);
  movements = movs.map(m => ({
    type: m.type, name: m.ingredient, time: fecha(m.created_at),
    detail: `${m.order_id ? 'TR-' + m.order_id + ' · ' : ''}${m.amount} · ${m.before_qty} → ${m.after_qty}` +
      `${m.reason ? ' · ' + m.reason : ''}${m.supplier ? ' · Proveedor: ' + m.supplier : ''}${m.note ? ' · ' + m.note : ''}`
  }));
  if (!orders.some(o => o.id === selectedOrderId)) selectedOrderId = orders[0]?.id || null;
  renderAll();
}

async function act(fn, msg) {
  try { await fn(); await loadAll(); if (msg) toast(msg); }
  catch (e) { toast(e.message); }
}

changeStatus = async function (id, next) {
  const o = orders.find(x => x.id === id);
  if (next === 'En preparación' && !o.discounted) { requestConsumption(o); return; }
  act(() => api(`/api/orders/${o.dbId}/status`, { method: 'PATCH', body: { status: next } }),
      `${o.id} actualizado a ${next}.`);
};

consumeOrder = function (id) {
  const o = orders.find(x => x.id === id);
  act(() => api(`/api/orders/${o.dbId}/status`, { method: 'PATCH', body: { status: 'En preparación' } }),
      `Ingredientes descontados para ${o.id}.`);
};

confirmDelete = function (id) {
  const o = orders.find(x => x.id === id);
  if (!o || o.status !== 'Entregado') return;
  openConfirm('Eliminar pedido entregado',
    `<p>Enviarás manualmente <b>${o.id}</b> a Pedidos eliminados. No se borrará definitivamente.</p>`,
    () => act(() => api(`/api/orders/${o.dbId}/delete`, { method: 'PATCH' }),
              `Pedido ${o.id} enviado a Pedidos eliminados.`),
    'Eliminar pedido');
};

restoreDeleted = function (id) {
  const o = deletedOrders.find(x => x.id === id);
  if (!o) return;
  selectedOrderId = id;
  act(() => api(`/api/orders/${o.dbId}/restore`, { method: 'PATCH' }),
      `Pedido ${id} restaurado como Entregado; el inventario no se modificó.`);
};

permanentlyDelete = function (id) {
  const o = deletedOrders.find(x => x.id === id);
  if (!o) return;
  openConfirm('Eliminar definitivamente',
    `<p>Esta acción no se puede deshacer. ¿Eliminar definitivamente <b>${o.id}</b>?</p>`,
    () => act(() => api(`/api/orders/${o.dbId}`, { method: 'DELETE' }),
              `Pedido ${id} eliminado definitivamente.`),
    'Eliminar definitivamente');
};

document.getElementById('order-form').onsubmit = async e => {
  e.preventDefault();
  const customer = document.getElementById('new-customer').value.trim();
  const error = document.getElementById('order-form-error');
  if (!customer || !draft.length) {
    error.textContent = 'Indica el cliente y añade al menos un platillo.';
    error.classList.remove('hidden'); return;
  }
  try {
    await api('/api/orders', { method: 'POST', body: {
      customer, items: draft,
      notes: document.getElementById('new-notes').value.trim(),
      priority: document.getElementById('new-priority').value
    }});
    document.getElementById('order-modal').classList.remove('open');
    await loadAll(); toast('Pedido creado.');
  } catch (err) { error.textContent = err.message; error.classList.remove('hidden'); }
};

document.getElementById('adjust-form').onsubmit = async e => {
  e.preventDefault();
  const error = document.getElementById('adjust-error');
  const cost = document.getElementById('adjust-cost').value;
  try {
    await api(`/api/inventory/${adjustingId}/movement`, { method: 'POST', body: {
      type: document.getElementById('adjust-type').value,
      amount: +document.getElementById('adjust-quantity').value,
      reason: document.getElementById('adjust-reason').value,
      supplier: document.getElementById('adjust-supplier').value.trim(),
      cost: cost ? +cost : null,
      note: document.getElementById('adjust-note').value.trim()
    }});
    document.getElementById('adjust-modal').classList.remove('open');
    await loadAll(); toast('Movimiento registrado. Stock actualizado.');
  } catch (err) { error.textContent = err.message; error.classList.remove('hidden'); }
};

   document.getElementById('reset-demo').onclick = () =>
     openConfirm('Restaurar demostración',
       '<p>Se borrarán los pedidos y movimientos actuales, y se restaurarán los pedidos de ejemplo y el stock inicial.</p>',
       () => act(() => api('/api/reset', { method: 'POST' }), 'Datos de demostración restaurados.'),
       'Restaurar datos');

loadAll().catch(() => toast('No se pudo conectar con el servidor.'));
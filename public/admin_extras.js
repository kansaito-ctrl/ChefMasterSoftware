// ChefMaster · extras de administración: "Agregar a la mesa" y "Carta".
// Se carga DESPUÉS de api.js (ver <script src="/admin_extras.js"> en administracion.html).
(function () {
  const ORDEN = ["Tacos", "Guarniciones", "Entradas", "Segundo tiempo", "Plato fuerte", "Postres", "Bebidas", "Menú degustación", "Cocina turca"];
  const peso = v => new Intl.NumberFormat("es-MX", { style: "currency", currency: "MXN", maximumFractionDigits: 0 }).format(v);
  const esc = s => String(s ?? "").replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  const $ = id => document.getElementById(id);
  const porCategoria = () => {
    const grupos = {};
    Object.entries(recipes).forEach(([n, r]) => { (grupos[r.category || "Otros"] ||= []).push(n); });
    return Object.keys(grupos)
      .sort((a, b) => ((ORDEN.indexOf(a) + 100) % 100) - ((ORDEN.indexOf(b) + 100) % 100))
      .map(c => [c, grupos[c]]);
  };

  const css = document.createElement("style");
  css.textContent = `
    .tm-row,.cx-row{display:flex;flex-wrap:wrap;align-items:center;justify-content:space-between;gap:10px;padding:8px 0;border-bottom:2px solid #24211e}
    .tm-qty{display:flex;align-items:center;gap:8px;font-weight:800}
    .tm-qty button{width:36px;height:36px;border:2px solid #24211e;border-radius:9px;background:#e0aa29;font-size:20px;font-weight:800;cursor:pointer}
    .tm-cat{margin:14px 0 4px;font-weight:800;color:#d73a31;text-transform:uppercase;letter-spacing:.08em;font-size:13px}
    .cx-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:12px;margin-top:10px}
    .cx-ing{display:grid;grid-template-columns:2fr 1fr auto auto;gap:8px;margin-top:8px;align-items:center}
    .cx-row .field{width:110px}
  `;
  document.head.appendChild(css);

  // ================= Agregar a la mesa =================
  let tmOrder = null, tmQty = {}, tmNames = [];
  const modal = document.createElement("div");
  modal.className = "modal";
  modal.style.cssText = "position:fixed;inset:0;z-index:45;align-items:center;justify-content:center;background:rgba(0,0,0,.6);padding:16px";
  modal.innerHTML = `
    <div class="paper" style="width:100%;max-width:560px;max-height:90vh;display:flex;flex-direction:column;padding:18px;background:#fff8e8" role="dialog" aria-modal="true">
      <div style="display:flex;justify-content:space-between;gap:8px">
        <div><p style="color:#d73a31;font-weight:800;text-transform:uppercase;letter-spacing:.1em;font-size:13px">Agregar a la mesa</p>
          <h2 id="tm-title" class="brand" style="font-size:22px;font-weight:800"></h2></div>
        <button id="tm-close" class="comic-btn btn-paper" type="button" aria-label="Cerrar">✕</button>
      </div>
      <div id="tm-list" style="overflow:auto;margin:12px 0;flex:1"></div>
      <p id="tm-error" style="color:#d73a31;font-weight:700;min-height:20px"></p>
      <button id="tm-send" class="comic-btn btn-red" style="width:100%" type="button">Agregar al pedido</button>
    </div>`;
  document.body.appendChild(modal);
  $("tm-close").onclick = () => modal.classList.remove("open");

  function openTable(o) {
    tmOrder = o; tmQty = {}; tmNames = [];
    $("tm-title").textContent = `${o.id} · ${o.customer}`;
    $("tm-error").textContent = "";
    $("tm-list").innerHTML = porCategoria().map(([cat, nombres]) =>
      `<div class="tm-cat">${esc(cat)}</div>` + nombres.filter(n => recipes[n].active !== false).map(n => {
        const i = tmNames.push(n) - 1;
        return `<div class="tm-row"><div><b>${esc(n)}</b><div style="font-size:13px;font-weight:700">${peso(recipes[n].price)}</div></div>
          <div class="tm-qty"><button type="button" data-i="${i}" data-d="-1" aria-label="Quitar uno">−</button>
          <span id="tm-q${i}">0</span><button type="button" data-i="${i}" data-d="1" aria-label="Agregar uno">+</button></div></div>`;
      }).join("")).join("");
    $("tm-list").querySelectorAll(".tm-qty button").forEach(b => b.onclick = () => {
      const n = tmNames[+b.dataset.i], q = Math.max(0, Math.min(50, (tmQty[n] || 0) + +b.dataset.d));
      if (q) tmQty[n] = q; else delete tmQty[n];
      $("tm-q" + b.dataset.i).textContent = q;
    });
    modal.classList.add("open");
  }

  $("tm-send").onclick = () => {
    const items = Object.entries(tmQty).map(([name, qty]) => ({ name, qty }));
    if (!items.length) { $("tm-error").textContent = "Elige al menos un platillo."; return; }
    modal.classList.remove("open");
    act(() => api(`/api/orders/${tmOrder.dbId}/items`, { method: "POST", body: { items } }),
        `Se agregó a ${tmOrder.id}.`);
  };

  const _renderOrderDetail = renderOrderDetail;
  renderOrderDetail = function () {
    _renderOrderDetail();
    const o = orders.find(x => x.id === selectedOrderId), host = $("order-detail");
    if (!o || o.status === "Entregado" || !host.firstElementChild) return;
    const b = document.createElement("button");
    b.type = "button"; b.className = "comic-btn btn-gold w-full mt-4";
    b.textContent = "+ Agregar platillos a esta mesa";
    b.onclick = () => openTable(o);
    host.appendChild(b);
  };

  // ================= Carta (Configuración) =================
  const sec = document.createElement("section");
  sec.className = "paper p-5 lg:col-span-2";
  sec.innerHTML = `
    <h3 class="brand font-bold" style="font-size:19px;font-weight:800">Carta</h3>
    <p class="font-semibold" style="margin:6px 0 12px">Cambia precios, oculta platillos del menú del cliente o añade uno nuevo.</p>
    <div id="carta-list"></div>
    <hr style="border:2px solid #24211e;margin:18px 0">
    <h4 class="brand" style="font-size:17px;font-weight:800">Añadir algo nuevo a la carta</h4>
    <div class="cx-grid">
      <div><label class="block font-bold mb-1" for="cx-name">Nombre</label><input id="cx-name" class="field" type="text" maxlength="100"></div>
      <div><label class="block font-bold mb-1" for="cx-cat">Categoría</label><input id="cx-cat" class="field" type="text" list="cx-cats" maxlength="40" placeholder="Tacos, Postres…"></div>
      <div><label class="block font-bold mb-1" for="cx-price">Precio</label><input id="cx-price" class="field" type="number" min="0" step="1"></div>
      <div><label class="block font-bold mb-1" for="cx-img">Foto (ruta o enlace)</label><input id="cx-img" class="field" type="text" maxlength="255" placeholder="/img/mi-platillo.jpg"></div>
    </div>
    <label class="block font-bold mb-1" style="margin-top:12px" for="cx-desc">Descripción para el cliente</label>
    <textarea id="cx-desc" class="field" rows="2" placeholder="Ingredientes y cómo se sirve"></textarea>
    <p class="font-bold" style="margin-top:12px">Ingredientes (cantidad por una porción)</p>
    <div id="cx-ings"></div>
    <button id="cx-add-ing" class="comic-btn btn-paper" style="margin-top:8px" type="button">+ Ingrediente</button>
    <datalist id="cx-cats"></datalist><datalist id="cx-ing-list"></datalist>
    <p id="cx-error" style="color:#d73a31;font-weight:700;margin-top:10px;min-height:20px"></p>
    <button id="cx-save" class="comic-btn btn-red" type="button">Añadir a la carta</button>`;
  document.querySelector("#configuracion .grid").appendChild(sec);

  function addIngRow() {
    const row = document.createElement("div");
    row.className = "cx-ing";
    row.innerHTML = `<input class="field" list="cx-ing-list" placeholder="Ingrediente" aria-label="Ingrediente">
      <input class="field" type="number" min="0" step="0.01" placeholder="Cantidad" aria-label="Cantidad">
      <span class="cx-unit font-bold"></span><button class="comic-btn btn-paper" type="button" aria-label="Quitar">✕</button>`;
    const [nom] = row.querySelectorAll("input");
    nom.addEventListener("input", () => {
      const ing = inventory.find(i => i.name === nom.value.trim());
      row.querySelector(".cx-unit").textContent = ing ? ing.unit : "";
    });
    row.querySelector("button").onclick = () => row.remove();
    $("cx-ings").appendChild(row);
  }
  $("cx-add-ing").onclick = addIngRow;
  addIngRow(); addIngRow();

  $("cx-save").onclick = async () => {
    const err = $("cx-error"); err.textContent = "";
    const body = {
      name: $("cx-name").value.trim(), category: $("cx-cat").value.trim(),
      price: parseFloat($("cx-price").value), description: $("cx-desc").value.trim(), image_url: $("cx-img").value.trim(),
      ingredients: [...$("cx-ings").children].map(r => {
        const [n, q] = r.querySelectorAll("input");
        return { name: n.value.trim(), qty: parseFloat(q.value) };
      }).filter(i => i.name && i.qty > 0)
    };
    if (!body.name || !body.category || !(body.price >= 0) || !body.ingredients.length) {
      err.textContent = "Completa nombre, categoría, precio y al menos un ingrediente con cantidad."; return;
    }
    try {
      await api("/api/recipes", { method: "POST", body });
      ["cx-name", "cx-cat", "cx-price", "cx-desc", "cx-img"].forEach(id => { $(id).value = ""; });
      $("cx-ings").innerHTML = ""; addIngRow(); addIngRow();
      await loadAll(); toast("Platillo añadido a la carta.");
    } catch (e) { err.textContent = e.message; }
  };

  function renderCarta() {
    if (!Object.keys(recipes).length) return;
    $("cx-cats").innerHTML = porCategoria().map(([c]) => `<option value="${esc(c)}">`).join("");
    $("cx-ing-list").innerHTML = inventory.map(i => `<option value="${esc(i.name)}">`).join("");
    $("carta-list").innerHTML = porCategoria().map(([cat, nombres]) =>
      `<div class="tm-cat">${esc(cat)}</div>` + nombres.map(n => `
        <div class="cx-row">${recipes[n].image_url ? `<img src="${esc(recipes[n].image_url)}" alt="" style="width:44px;height:44px;object-fit:cover;border:2px solid #24211e;border-radius:8px" onerror="this.remove()">` : ""}<b style="flex:1;min-width:160px">${esc(n)}</b>
          <label class="font-bold">$ <input class="field cx-precio" type="number" min="0" step="1" value="${recipes[n].price}" data-n="${esc(n)}"></label>
          <label class="font-bold"><input type="checkbox" class="cx-vis" data-n="${esc(n)}" ${recipes[n].active !== false ? "checked" : ""}> Visible</label>
          <input class="field cx-foto" type="text" style="width:200px" placeholder="/img/archivo.jpg" value="${esc(recipes[n].image_url || "")}" data-n="${esc(n)}" aria-label="Foto de ${esc(n)}">
        </div>`).join("")).join("");
    $("carta-list").querySelectorAll(".cx-precio").forEach(inp => inp.onchange = () => {
      const p = parseFloat(inp.value);
      if (!(p >= 0)) return;
      act(() => api(`/api/recipes/${recipes[inp.dataset.n].id}`, { method: "PATCH", body: { price: p } }), "Precio actualizado.");
    });
    $("carta-list").querySelectorAll(".cx-foto").forEach(inp => inp.onchange = () =>
      act(() => api(`/api/recipes/${recipes[inp.dataset.n].id}`, { method: "PATCH", body: { image_url: inp.value.trim() } }), "Foto actualizada."));
    $("carta-list").querySelectorAll(".cx-vis").forEach(chk => chk.onchange = () =>
      act(() => api(`/api/recipes/${recipes[chk.dataset.n].id}`, { method: "PATCH", body: { active: chk.checked } }),
          chk.checked ? "Platillo visible en el menú." : "Platillo oculto del menú."));
    // el selector de "Crear pedido" solo muestra platillos visibles
    const sel = $("new-product"), cur = sel.value;
    sel.innerHTML = Object.keys(recipes).filter(n => recipes[n].active !== false)
      .map(n => `<option value="${esc(n)}">${esc(n)}</option>`).join("");
    if ([...sel.options].some(o => o.value === cur)) sel.value = cur;
  }

  const _renderAll = renderAll;
  renderAll = function () { _renderAll(); renderCarta(); };
  renderCarta();

  // ================= Textos: quitar "demostración" y "turco" =================
  const setText = (tpl, txt) => { const el = document.querySelector(`[data-template-id="${tpl}"]`); if (el) el.textContent = txt; };
  setText("app-tagline", "OPERACIONES DE COCINA");
  setText("shift-status", "Cocina abierta");
  setText("home-date", new Date().toLocaleDateString("es-MX", { weekday: "long", day: "numeric", month: "long" }));
  setText("sidebar-note-text", "Cada pedido preparado descuenta el almacén una sola vez.");
  setText("reports-note", "Información en tiempo real del servicio.");
  setText("report-summary-title", "Resumen");
  const _renderReports = renderReports;
  renderReports = function () {
    _renderReports();
    const s = $("report-summary");
    if (s) s.innerHTML = s.innerHTML.replace("Datos de demostración de la sesión actual.", "Información del servicio actual.");
  };

  // ================= Pedidos: detalle junto a la lista =================
  const css2 = document.createElement("style");
  css2.textContent = `
    @media (min-width:1024px){
      #pedidos [class*="lg:grid-cols-5"] > section:nth-of-type(1){grid-column:1 / span 3;grid-row:1}
      #pedidos [class*="lg:grid-cols-5"] > section:nth-of-type(2){grid-column:1 / span 3;grid-row:2}
      #pedidos [class*="lg:grid-cols-5"] > aside{grid-column:4 / span 2;grid-row:1;align-self:start;position:sticky;top:12px}
    }
    .inv-bar{height:8px;margin-top:4px;border:2px solid #24211e;border-radius:99px;background:#fffdf6;overflow:hidden;min-width:90px}
    .inv-bar span{display:block;height:100%}
    .inv-base{font-size:12px;font-weight:700;opacity:.8}
    #live{margin-left:12px;font-size:13px;font-weight:700}
  `;
  document.head.appendChild(css2);

  // ================= Inventario: orden alfabético y "restante" =================
  const num = new Intl.NumberFormat("es-MX", { maximumFractionDigits: 2 });
  const _renderInventory = renderInventory;
  renderInventory = function () {
    inventory.sort((a, b) => a.name.localeCompare(b.name, "es"));
    _renderInventory();
    const th = document.querySelectorAll("#inventario thead th");
    if (th[2]) th[2].textContent = "Restante";
    if (th[3]) th[3].textContent = "Mínimo base";
    document.querySelectorAll("#inventory-table tr").forEach(tr => {
      const c = tr.children, ing = inventory.find(i => i.name === c[0].textContent.trim());
      if (!ing) return;
      const base = Number(ing.base_quantity) || 0, q = Number(ing.quantity);
      const pct = base ? Math.max(0, Math.min(100, Math.round(q / base * 100))) : 0;
      const color = q <= 0 ? "#d73a31" : q <= ing.minimum ? "#e0aa29" : "#4e977b";
      c[2].innerHTML = `<b>${num.format(q)} ${esc(ing.unit)}</b>` + (base
        ? `<div class="inv-base">de ${num.format(base)} ${esc(ing.unit)} · ${pct}%</div><div class="inv-bar"><span style="width:${pct}%;background:${color}"></span></div>` : "");
      c[3].textContent = `${num.format(ing.minimum)} ${ing.unit}`;
    });
  };

  // ================= En vivo: se actualiza solo cada 5 segundos =================
  const live = document.createElement("span");
  live.id = "live"; live.textContent = "● En vivo";
  const shift = document.querySelector('[data-template-id="shift-status"]');
  if (shift) shift.parentElement.appendChild(live);
  const _loadAll = loadAll;
  loadAll = async function () {
    await _loadAll();
    live.textContent = "● En vivo · " + new Date().toLocaleTimeString("es-MX", { hour: "2-digit", minute: "2-digit", second: "2-digit" });
  };
  setInterval(() => {
    const el = document.activeElement;   // no se actualiza si estás escribiendo o hay una ventana abierta
    if (document.hidden || document.querySelector(".modal.open") || (el && /^(INPUT|SELECT|TEXTAREA)$/.test(el.tagName))) return;
    loadAll().catch(() => {});
  }, 5000);
  // ================= Costeo de la carta (ganancia, mano de obra y margen de error) =================
  const CFG_KEY = "chefmaster_costeo";
  const cfg = (() => {
    const base = { g: 45, mo: 10, err: 10, modo: "venta" };
    try { return Object.assign(base, JSON.parse(localStorage.getItem(CFG_KEY) || "{}")); } catch (e) { return base; }
  })();
  const pesos = v => new Intl.NumberFormat("es-MX", { style: "currency", currency: "MXN", minimumFractionDigits: 2 }).format(v);

  const cs = document.createElement("section");
  cs.className = "paper p-5 lg:col-span-2";
  cs.innerHTML = `
    <h3 class="brand font-bold" style="font-size:19px;font-weight:800">Costeo de la carta</h3>
    <p class="font-semibold" style="margin:6px 0 12px">El precio sugerido sale del costo real de los insumos de cada receta, más mano de obra, margen de error y ganancia.</p>
    <div class="cx-grid">
      <div><label class="block font-bold mb-1" for="cs-g">Ganancia (%)</label><input id="cs-g" class="field" type="number" min="0" max="95" step="1"></div>
      <div><label class="block font-bold mb-1" for="cs-mo">Mano de obra (%)</label><input id="cs-mo" class="field" type="number" min="0" max="95" step="1"></div>
      <div><label class="block font-bold mb-1" for="cs-err">Margen de error (%)</label><input id="cs-err" class="field" type="number" min="0" max="95" step="1"></div>
      <div><label class="block font-bold mb-1">Total de margen</label><div id="cs-total" class="field" style="font-weight:800"></div></div>
      <div><label class="block font-bold mb-1" for="cs-modo">Los porcentajes se aplican</label>
        <select id="cs-modo" class="field"><option value="venta">Sobre el precio de venta</option><option value="costo">Sumados al costo</option></select></div>
    </div>
    <p id="cs-nota" class="font-semibold" style="margin:10px 0"></p>
    <div style="overflow-x:auto"><table style="min-width:900px"><thead><tr>
      <th>Platillo</th><th>Costo de insumos</th><th>Mano de obra</th><th>Margen de error</th><th>Ganancia</th><th>Precio sugerido</th><th>Precio actual</th><th>Margen actual</th><th></th>
    </tr></thead><tbody id="cs-body"></tbody></table></div>
    <button id="cs-todos" class="comic-btn btn-red" type="button" style="margin-top:12px">Aplicar precios sugeridos a toda la carta</button>`;
  document.querySelector("#configuracion .grid").appendChild(cs);

  $("cs-g").value = cfg.g; $("cs-mo").value = cfg.mo; $("cs-err").value = cfg.err; $("cs-modo").value = cfg.modo;
  const guardarCfg = () => { try { localStorage.setItem(CFG_KEY, JSON.stringify(cfg)); } catch (e) {} };
  [["cs-g", "g"], ["cs-mo", "mo"], ["cs-err", "err"]].forEach(([id, k]) =>
    $(id).addEventListener("input", () => { cfg[k] = Math.max(0, Math.min(95, parseFloat($(id).value) || 0)); guardarCfg(); renderCosteo(); }));
  $("cs-modo").addEventListener("change", () => { cfg.modo = $("cs-modo").value; guardarCfg(); renderCosteo(); });

  function costoDe(nombre) {
    let total = 0, sinPrecio = 0;
    for (const [ing, qty] of recipes[nombre].ingredients) {
      const i = inventory.find(x => x.name === ing), p = i ? Number(i.price) : 0;
      if (!p) sinPrecio++;
      total += Number(qty) * p;
    }
    return { total, sinPrecio };
  }
  function sugerido(costo) {
    const pct = (cfg.g + cfg.mo + cfg.err) / 100;
    const venta = cfg.modo === "venta";
    if (venta && pct >= 1) return null;
    const precio = venta ? costo / (1 - pct) : costo * (1 + pct), base = venta ? precio : costo;
    return { precio, mo: base * cfg.mo / 100, err: base * cfg.err / 100, g: base * cfg.g / 100 };
  }
  const activos = () => porCategoria().flatMap(([, nombres]) => nombres).filter(n => recipes[n].active !== false);

  function renderCosteo() {
    if (!Object.keys(recipes).length) return;
    const total = cfg.g + cfg.mo + cfg.err;
    $("cs-total").textContent = total + "%";
    $("cs-nota").textContent = cfg.modo === "venta"
      ? `Cada porcentaje es parte del precio de venta: los insumos representan el ${Math.max(0, 100 - total)}% y el precio = costo ÷ ${(Math.max(0, 100 - total) / 100).toFixed(2)}.`
      : `Los porcentajes se suman al costo de los insumos: precio = costo × ${(1 + total / 100).toFixed(2)}.`;
    if (cfg.modo === "venta" && total >= 100) { $("cs-body").innerHTML = '<tr><td colspan="9"><b>Los porcentajes suman 100% o más: baja alguno.</b></td></tr>'; return; }
    $("cs-body").innerHTML = activos().map(n => {
      const c = costoDe(n), r = recipes[n];
      if (!c.total) return `<tr><td><b>${esc(n)}</b></td><td colspan="8">Sin costo: revisa los precios de sus ingredientes.</td></tr>`;
      const s = sugerido(c.total), redondo = Math.ceil(s.precio), actual = Number(r.price);
      const margen = actual ? Math.round((actual - c.total) / actual * 100) : 0;
      return `<tr><td><b>${esc(n)}</b>${c.sinPrecio ? `<div class="inv-base">${c.sinPrecio} ingrediente(s) sin precio</div>` : ""}</td>
        <td>${pesos(c.total)}</td><td>${pesos(s.mo)}</td><td>${pesos(s.err)}</td><td>${pesos(s.g)}</td>
        <td><b>${pesos(redondo)}</b></td><td>${pesos(actual)}</td><td>${margen}%</td>
        <td>${redondo === actual ? "✓" : `<button class="comic-btn btn-mint cs-aplicar" type="button" data-n="${esc(n)}" data-p="${redondo}">Aplicar</button>`}</td></tr>`;
    }).join("");
    $("cs-body").querySelectorAll(".cs-aplicar").forEach(b => b.onclick = () =>
      act(() => api(`/api/recipes/${recipes[b.dataset.n].id}`, { method: "PATCH", body: { price: +b.dataset.p } }), "Precio actualizado."));
  }
  $("cs-todos").onclick = () => openConfirm("Aplicar precios sugeridos",
    "<p>Se cambiará el precio de venta de <b>todos los platillos visibles</b> con el precio sugerido de esta tabla.</p>",
    () => act(async () => {
      for (const n of activos()) {
        const c = costoDe(n), s = c.total && sugerido(c.total);
        if (s) await api(`/api/recipes/${recipes[n].id}`, { method: "PATCH", body: { price: Math.ceil(s.precio) } });
      }
    }, "Precios actualizados en toda la carta."), "Aplicar a toda la carta");

  const _renderAll2 = renderAll;
  renderAll = function () { _renderAll2(); renderCosteo(); };
  renderCosteo();
})();
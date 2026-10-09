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
      price: parseFloat($("cx-price").value), description: $("cx-desc").value.trim(),
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
      ["cx-name", "cx-cat", "cx-price", "cx-desc"].forEach(id => { $(id).value = ""; });
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
        <div class="cx-row"><b style="flex:1;min-width:180px">${esc(n)}</b>
          <label class="font-bold">$ <input class="field cx-precio" type="number" min="0" step="1" value="${recipes[n].price}" data-n="${esc(n)}"></label>
          <label class="font-bold"><input type="checkbox" class="cx-vis" data-n="${esc(n)}" ${recipes[n].active !== false ? "checked" : ""}> Visible</label>
        </div>`).join("")).join("");
    $("carta-list").querySelectorAll(".cx-precio").forEach(inp => inp.onchange = () => {
      const p = parseFloat(inp.value);
      if (!(p >= 0)) return;
      act(() => api(`/api/recipes/${recipes[inp.dataset.n].id}`, { method: "PATCH", body: { price: p } }), "Precio actualizado.");
    });
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
})();
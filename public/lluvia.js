/* ChefMaster · lluvia de ingredientes de fondo para la pantalla de inicio.
   Se carga desde index.html con una etiqueta script.   Respeta "reducir animaciones" del sistema.   */
(function (root) {
  'use strict';
  var d = root.document;
  if (!d || !d.body) return;
  if (root.matchMedia && root.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  var NOMBRES = ["tomate", "chile", "zanahoria", "cebolla", "ajo", "limon", "aguacate", "hongo", "hoja", "huevo"];
  var SIMBOLOS = '<svg width="0" height="0" style="position:absolute" aria-hidden="true" focusable="false"><symbol id="ing-tomate" viewBox="0 0 64 64"><g stroke="#111" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"><circle cx="32" cy="36" r="21" fill="#d8412f"/><path d="M32 20 L26 12 L31 15 L32 8 L35 15 L40 12 Z" fill="#4e977b"/><path d="M19 32 Q21 25 27 23" fill="none" stroke="#fff9e9"/></g></symbol><symbol id="ing-chile" viewBox="0 0 64 64"><g stroke="#111" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"><path d="M16 20 C34 12 56 24 52 48 C50 58 40 54 38 46 C36 36 28 30 16 30 Z" fill="#d8412f"/><path d="M16 20 C10 18 8 12 12 8 C14 14 18 14 20 16 Z" fill="#4e977b"/><path d="M26 22 Q36 22 42 30" fill="none" stroke="#fff9e9"/></g></symbol><symbol id="ing-zanahoria" viewBox="0 0 64 64"><g stroke="#111" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"><path d="M24 24 L40 24 L33 60 Z" fill="#f08a24"/><path d="M28 34 h6 M29 44 h4" fill="none"/><path d="M32 24 C24 18 22 10 26 6 C30 10 32 16 32 24 Z M32 24 C34 14 40 8 44 8 C44 14 40 20 32 24 Z" fill="#4e977b"/></g></symbol><symbol id="ing-cebolla" viewBox="0 0 64 64"><g stroke="#111" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"><path d="M32 8 C34 18 50 24 50 40 C50 52 42 58 32 58 C22 58 14 52 14 40 C14 24 30 18 32 8 Z" fill="#b66aa8"/><path d="M32 22 C24 32 24 46 32 56 M32 22 C40 32 40 46 32 56" fill="none" stroke="#fff9e9"/><path d="M28 58 l-2 4 M36 58 l2 4" fill="none"/></g></symbol><symbol id="ing-ajo" viewBox="0 0 64 64"><g stroke="#111" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"><path d="M32 8 C35 18 50 24 48 40 C46 54 38 58 32 58 C26 58 18 54 16 40 C14 24 29 18 32 8 Z" fill="#fff9e9"/><path d="M32 20 C26 32 26 46 32 56 M32 20 C38 32 38 46 32 56" fill="none"/></g></symbol><symbol id="ing-limon" viewBox="0 0 64 64"><g stroke="#111" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"><path d="M6 32 L12 29 C16 20 24 14 32 14 C42 14 52 20 54 29 L60 32 L54 35 C52 44 42 50 32 50 C22 50 12 44 12 35 Z" fill="#f4c84a"/><path d="M20 26 Q24 20 32 20" fill="none" stroke="#fff9e9"/></g></symbol><symbol id="ing-aguacate" viewBox="0 0 64 64"><g stroke="#111" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"><path d="M32 5 C41 5 44 17 46 27 C53 36 55 45 50 53 C45 61 19 61 14 53 C9 45 11 36 18 27 C20 17 23 5 32 5 Z" fill="#4e977b"/><path d="M32 12 C38 12 40 22 42 30 C47 37 48 44 45 50 C41 56 23 56 19 50 C16 44 17 37 22 30 C24 22 26 12 32 12 Z" fill="#c9e29a"/><circle cx="32" cy="42" r="8" fill="#8a5a2b"/></g></symbol><symbol id="ing-hongo" viewBox="0 0 64 64"><g stroke="#111" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"><path d="M24 34 H40 V50 C40 58 24 58 24 50 Z" fill="#fff9e9"/><path d="M6 34 C6 16 18 8 32 8 C46 8 58 16 58 34 Z" fill="#c8956a"/><path d="M16 26 Q20 18 28 15" fill="none" stroke="#e9cfa6"/></g></symbol><symbol id="ing-hoja" viewBox="0 0 64 64"><g stroke="#111" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"><path d="M32 60 C30 42 12 38 10 18 C22 20 28 24 32 32 C36 24 42 20 54 18 C52 38 34 42 32 60 Z" fill="#4e977b"/><path d="M32 58 V30" fill="none" stroke="#c9e29a"/></g></symbol><symbol id="ing-huevo" viewBox="0 0 64 64"><g stroke="#111" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"><path d="M32 6 C46 6 54 26 54 38 C54 51 44 59 32 59 C20 59 10 51 10 38 C10 26 18 6 32 6 Z" fill="#fff9e9"/><path d="M20 30 Q22 20 28 16" fill="none"/></g></symbol></svg>';
  var CSS = '.lluvia{position:fixed;inset:0;z-index:0;pointer-events:none;overflow:hidden}' +
    '.lluvia .ing{position:absolute;top:0;left:var(--x);width:var(--s);height:var(--s);opacity:var(--o);will-change:transform;animation:ing-caer var(--d) linear var(--r) infinite}' +
    '@keyframes ing-caer{from{transform:translate3d(0,-14vh,0) rotate(0deg)}to{transform:translate3d(var(--dx),114vh,0) rotate(var(--giro))}}' +
    'main{position:relative;z-index:1}';

  var st = d.createElement('style'); st.textContent = CSS; d.head.appendChild(st);
  var capa = d.createElement('div'); capa.className = 'lluvia'; capa.setAttribute('aria-hidden', 'true');
  var html = SIMBOLOS;
  var ancho = root.innerWidth || 1024, k = ancho < 520 ? 0.75 : 1;
  var n = Math.max(14, Math.min(36, Math.round(ancho / 50)));
  for (var i = 0; i < n; i++) {
    var t = Math.random(), s = Math.round((30 + t * 40) * k);            // los grandes se ven "más cerca": más rápidos y más nítidos
    var dur = (15 - t * 7).toFixed(1), giro = (Math.random() < 0.5 ? -1 : 1) * Math.round(90 + Math.random() * 270);
    var estilo = '--x:' + (Math.random() * 96).toFixed(1) + '%;--s:' + s + 'px;--o:' + (0.45 + t * 0.45).toFixed(2) +
      ';--d:' + dur + 's;--r:-' + (Math.random() * dur).toFixed(1) + 's;--dx:' + Math.round((Math.random() - 0.5) * 80) + 'px;--giro:' + giro + 'deg';
    html += '<svg class="ing" style="' + estilo + '" viewBox="0 0 64 64" aria-hidden="true"><use href="#ing-' + NOMBRES[Math.floor(Math.random() * NOMBRES.length)] + '"/></svg>';
  }
  capa.innerHTML = html;
  d.body.insertBefore(capa, d.body.firstChild);
})(typeof window !== 'undefined' ? window : globalThis);
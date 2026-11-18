/* ChefMaster · "¡NO!" estilo dibujo animado de los años 30 (guante blanco, tinta gruesa y dedo que dice que no).
   Uso:  mostrarNo("Contraseña incorrecta");     NoNo.sacudir(elemento);                                   */
(function (root) {
  'use strict';
  var d = root.document;
  if (!d) return;
  var capa, caja, titulo, texto, timer, anterior, ultimo = { m: '', t: 0 };

  var MANO = '<svg class="nono-mano" viewBox="0 0 200 260" aria-hidden="true"><g class="g" stroke="#111" stroke-width="6" stroke-linejoin="round" stroke-linecap="round" fill="#fff">' +
    '<path d="M85 150 L85 56 C85 36 115 36 115 56 L115 150 Z"/>' +
    '<path d="M62 236 C46 206 44 168 64 150 C76 138 124 138 136 150 C156 168 154 206 138 236 Z"/>' +
    '<path d="M64 176 C42 160 26 178 36 194 C46 208 66 206 76 198"/>' +
    '<path d="M118 158 C134 154 144 164 140 174 M118 180 C132 178 142 188 138 198 M118 202 C130 202 136 210 133 218" fill="none"/>' +
    '<path d="M86 180 v16 M99 178 v18" stroke-width="5" fill="none"/>' +
    '<rect x="56" y="228" width="88" height="26" rx="9"/><path d="M97 62 v26" stroke-width="4" fill="none"/></g>' +
    '<g stroke="#111" stroke-width="5" stroke-linecap="round" fill="none" class="aire"><path d="M30 60 q-12 22 0 44"/><path d="M170 60 q12 22 0 44"/></g></svg>';

  var GRANO = "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='160' height='160'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='2' stitchTiles='stitch'/></filter><rect width='100%25' height='100%25' filter='url(%23n)'/></svg>\")";
  var CSS = '.nono-capa{position:fixed;inset:0;z-index:9999;display:none;align-items:center;justify-content:center;padding:16px;background:rgba(20,16,12,.62)}' +
    '.nono-capa.abierta{display:flex}' +
    '.nono-caja{position:relative;width:min(92vw,380px);padding:16px 18px 20px;background:#f7e9c7;border:6px solid #111;border-radius:22px;box-shadow:9px 9px 0 #111;text-align:center;overflow:hidden;outline:none;cursor:pointer;animation:nono-pop .42s steps(7,end) both}' +
    '.nono-caja::after{content:"";position:absolute;inset:0;pointer-events:none;background:radial-gradient(ellipse at center,transparent 55%,rgba(120,80,30,.38) 100%)}' +
    '.nono-grano{position:absolute;inset:-24px;pointer-events:none;opacity:.16;background-image:' + GRANO + ';animation:nono-grano .3s steps(3) infinite}' +
    '.nono-mano{position:relative;width:150px;height:auto;display:block;margin:0 auto;overflow:visible}' +
    '.nono-mano .g{transform-origin:100px 244px;animation:nono-wag .55s steps(6,end) infinite}' +
    '.nono-mano .aire{animation:nono-aire .55s steps(2,end) infinite}' +
    '.nono-no{position:relative;font-family:Impact,"Arial Black",sans-serif;font-size:56px;line-height:1;letter-spacing:2px;color:#d8412f;-webkit-text-stroke:3px #111;paint-order:stroke fill;margin:4px 0;transform:rotate(-4deg);animation:nono-rebote .55s steps(4) infinite}' +
    '.nono-msg{position:relative;margin:8px 4px 0;font-family:Georgia,serif;font-weight:900;font-size:19px;line-height:1.3;color:#111}' +
    '.nono-sub{position:relative;margin:10px 0 0;font:700 11px "Trebuchet MS",Arial,sans-serif;color:#62584c;letter-spacing:.08em;text-transform:uppercase}' +
    '@keyframes nono-pop{0%{transform:scale(.5) rotate(-6deg)}60%{transform:scale(1.08) rotate(2deg)}100%{transform:scale(1) rotate(0)}}' +
    '@keyframes nono-wag{0%{transform:rotate(-22deg)}50%{transform:rotate(22deg)}100%{transform:rotate(-22deg)}}' +
    '@keyframes nono-aire{0%{opacity:0}50%{opacity:1}100%{opacity:0}}' +
    '@keyframes nono-rebote{0%,100%{transform:rotate(-4deg) scale(1)}50%{transform:rotate(-4deg) scale(1.1,.92)}}' +
    '@keyframes nono-grano{0%{transform:translate(0,0)}33%{transform:translate(-8px,6px)}66%{transform:translate(6px,-8px)}100%{transform:translate(0,0)}}' +
    '@keyframes nono-sacudida{0%,100%{transform:translateX(0)}20%{transform:translateX(-10px) rotate(-1deg)}40%{transform:translateX(9px) rotate(1deg)}60%{transform:translateX(-6px)}80%{transform:translateX(4px)}}' +
    '.nono-sacudir{animation:nono-sacudida .5s steps(8,end)}' +
    '@media (prefers-reduced-motion:reduce){.nono-caja,.nono-mano .g,.nono-mano .aire,.nono-no,.nono-grano,.nono-sacudir{animation:none!important}}';

  function crear() {
    if (capa) return;
    var st = d.createElement('style'); st.textContent = CSS; d.head.appendChild(st);
    capa = d.createElement('div'); capa.className = 'nono-capa';
    capa.setAttribute('role', 'alertdialog'); capa.setAttribute('aria-modal', 'true'); capa.setAttribute('aria-labelledby', 'nono-msg');
    capa.innerHTML = '<div class="nono-caja" tabindex="-1"><div class="nono-grano"></div>' + MANO +
      '<div class="nono-no" aria-hidden="true">¡NO!</div><p class="nono-msg" id="nono-msg"></p><p class="nono-sub">Toca para cerrar</p></div>';
    d.body.appendChild(capa);
    caja = capa.querySelector('.nono-caja'); titulo = capa.querySelector('.nono-no'); texto = capa.querySelector('.nono-msg');
    capa.addEventListener('click', cerrar);
    d.addEventListener('keydown', function (e) { if (e.key === 'Escape') cerrar(); });
  }
  function cerrar() {
    if (!capa || !capa.classList.contains('abierta')) return;
    clearTimeout(timer); capa.classList.remove('abierta');
    if (anterior && anterior.focus) { try { anterior.focus({ preventScroll: true }); } catch (e) {} }
  }
  function mostrar(mensaje, opts) {
    opts = opts || {}; mensaje = String(mensaje || 'Eso no se puede hacer.');
    var ahora = Date.now();
    if (capa && capa.classList.contains('abierta') && ultimo.m === mensaje && ahora - ultimo.t < 1500) return;   // evita repetirlo dos veces
    ultimo = { m: mensaje, t: ahora };
    crear();
    texto.textContent = mensaje; titulo.textContent = opts.titulo || '¡NO!';
    caja.style.animation = 'none'; void caja.offsetWidth; caja.style.animation = '';   // reinicia la animación
    if (!capa.classList.contains('abierta')) anterior = d.activeElement;
    capa.classList.add('abierta');
    try { caja.focus({ preventScroll: true }); } catch (e) {}
    clearTimeout(timer); timer = setTimeout(cerrar, opts.duracion || Math.min(5200, 2400 + mensaje.length * 35));
  }
  function sacudir(el) {
    if (!el) return;
    crear();   // asegura que el estilo exista
    el.classList.remove('nono-sacudir'); void el.offsetWidth; el.classList.add('nono-sacudir');
    setTimeout(function () { el.classList.remove('nono-sacudir'); }, 560);
  }
  root.NoNo = { mostrar: mostrar, cerrar: cerrar, sacudir: sacudir };
  root.mostrarNo = mostrar;
})(typeof window !== 'undefined' ? window : globalThis);
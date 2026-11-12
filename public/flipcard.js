/* ChefMaster · FlipCard (versión en JavaScript puro del componente FlipCard de React Bits).
   Uso:  const carta = FlipCard(elemento, { tiltMax: 8 });   carta.flip();                           */
(function (root) {
  'use strict';
  var FLING = 0.16, HISTORY_MS = 90, SLOP = { fine: 4, coarse: 8 };
  var clamp = function (v, lo, hi) { return Math.min(hi, Math.max(lo, v)); };
  var snap = function (deg) { return Math.round(deg / 180) * 180; };
  var isBack = function (deg) { return Math.abs(Math.round(deg / 180)) % 2 === 1; };

  // Resorte:  x'' = (-k (x - destino) - c x') / m
  function Spring(value, k, c, m, eps) {
    this.x = value; this.to = value; this.v = 0; this.k = k; this.c = c; this.m = m || 1; this.eps = eps || 0.01; this.held = false;
  }
  Spring.prototype.atRest = function () { return Math.abs(this.x - this.to) < this.eps && Math.abs(this.v) < this.eps * 10; };
  Spring.prototype.step = function (dt) {
    var n = Math.max(1, Math.ceil(dt / 0.008)), h = dt / n;
    for (var i = 0; i < n; i++) {
      this.v += ((-this.k * (this.x - this.to) - this.c * this.v) / this.m) * h;
      this.x += this.v * h;
    }
    if (this.atRest()) { this.x = this.to; this.v = 0; }
  };

  function FlipCard(el, opts) {
    var o = Object.assign({ axis: 'y', flipOnClick: true, draggable: true, dragDistance: 0, tilt: true, tiltMax: 10, glare: true,
      hoverScale: 1.03, perspective: 1100, stiffness: 170, damping: 20, defaultFlipped: false, onFlipChange: null }, opts || {});
    var rotor = el.querySelector('.flip-card__rotor'), front = el.querySelector('.flip-card__face--front'),
        back = el.querySelector('.flip-card__face--back'), shadow = el.querySelector('.flip-card__shadow');
    var reduce = !!(root.matchMedia && root.matchMedia('(prefers-reduced-motion: reduce)').matches);
    var shown = !!o.defaultFlipped, target = shown ? 180 : 0, grip = null, raf = 0, last = 0;
    var turn = new Spring(target, o.stiffness, o.damping, 1, 0.05), tx = new Spring(0, 240, 24, 0.6, 0.02),
        ty = new Spring(0, 240, 24, 0.6, 0.02), lift = new Spring(1, 320, 26, 1, 0.0005), sheen = new Spring(0, 320, 26, 1, 0.002);
    var all = [turn, tx, ty, lift, sheen];

    el.setAttribute('data-axis', o.axis);
    if (o.draggable && !reduce) el.setAttribute('data-draggable', '');
    if (!o.glare) el.querySelectorAll('.flip-card__glare').forEach(function (g) { g.remove(); });

    function sync() {
      if (shown) el.setAttribute('data-flipped', ''); else el.removeAttribute('data-flipped');
      front.inert = shown; back.inert = !shown;
      front.setAttribute('aria-hidden', String(shown)); back.setAttribute('aria-hidden', String(!shown));
      if (reduce) el.setAttribute('data-fade', shown ? 'back' : 'front');
    }
    function paint() {
      if (reduce) return;
      var t = turn.x, p = 'perspective(' + o.perspective + 'px) scale(' + lift.x + ') ';
      rotor.style.transform = o.axis === 'x'
        ? p + 'rotateY(' + ty.x + 'deg) rotateX(' + (t + tx.x) + 'deg)'
        : p + 'rotateX(' + tx.x + 'deg) rotateY(' + (t + ty.x) + 'deg)';
      el.style.setProperty('--fc-sheen', sheen.x);
      if (shadow) {
        var f = Math.abs(Math.cos(t * Math.PI / 180));
        shadow.style.transform = (o.axis === 'x' ? 'scaleY(' : 'scaleX(') + (0.08 + 0.92 * f) + ')';
        shadow.style.opacity = 0.1 + 0.9 * f * f;
      }
    }
    function tick(now) {
      var dt = Math.min(0.05, (now - last) / 1000), active = false; last = now;
      all.forEach(function (s) {
        if (s.held || s.atRest()) return;
        s.step(dt); if (!s.atRest()) active = true;
      });
      paint(); raf = active ? root.requestAnimationFrame(tick) : 0;
    }
    function kick() { if (!raf) { last = root.performance.now(); raf = root.requestAnimationFrame(tick); } }
    function settle(to, velocity, instant) {
      target = to; turn.held = false; turn.to = to;
      if (instant || reduce) { turn.x = to; turn.v = 0; paint(); } else { turn.v = velocity || 0; kick(); }
      var next = isBack(to);
      if (next === shown) return;
      shown = next; sync();
      if (o.onFlipChange) o.onFlipChange(next);
    }
    function flip(instant) { settle(isBack(target) ? target - 180 : target + 180, 0, instant); }   // parte del destino: un 2.º toque a media animación la regresa
    function rest() { tx.to = 0; ty.to = 0; sheen.to = 0; lift.to = 1; kick(); }

    el.addEventListener('pointerdown', function (e) {
      if (e.button !== 0 || grip || (e.target.closest && e.target.closest('button, a, input, select, textarea, [data-no-flip]'))) return;
      try { el.setPointerCapture(e.pointerId); } catch (err) {}
      turn.held = false; turn.to = turn.x; turn.v = 0;
      grip = { id: e.pointerId, x: e.clientX, y: e.clientY, base: turn.x, moved: false, slop: e.pointerType === 'touch' ? SLOP.coarse : SLOP.fine, hist: [] };
      if (!reduce) { lift.to = o.hoverScale; kick(); }
    });
    el.addEventListener('pointermove', function (e) {
      var g = grip;
      if (g && g.id === e.pointerId) {
        var d = o.axis === 'x' ? e.clientY - g.y : e.clientX - g.x;
        if (!g.moved) {
          if (Math.abs(d) < g.slop || !o.draggable || reduce) return;
          g.moved = true; el.setAttribute('data-dragging', ''); tx.to = 0; ty.to = 0; sheen.to = 0; kick();
        }
        var span = o.dragDistance > 0 ? o.dragDistance : (o.axis === 'x' ? el.offsetHeight : el.offsetWidth) || 300;
        var deg = g.base + (o.axis === 'x' ? -1 : 1) * (d / span) * 180;
        turn.held = true; turn.x = deg; turn.v = 0; paint();
        var now = root.performance.now(); g.hist.push({ t: now, v: deg });
        while (g.hist.length > 2 && now - g.hist[0].t > HISTORY_MS) g.hist.shift();
        return;
      }
      if (!o.tilt || reduce || e.pointerType === 'touch') return;
      var r = el.getBoundingClientRect(); if (!r.width || !r.height) return;
      var px = clamp((e.clientX - r.left) / r.width, 0, 1), py = clamp((e.clientY - r.top) / r.height, 0, 1);
      tx.to = (0.5 - py) * 2 * o.tiltMax; ty.to = (px - 0.5) * 2 * o.tiltMax; sheen.to = 1;
      el.style.setProperty('--fc-gx', px * 100 + '%'); el.style.setProperty('--fc-gy', py * 100 + '%'); kick();
    });
    function release(e, cancelled) {
      var g = grip; if (!g || g.id !== e.pointerId) return;
      grip = null; el.removeAttribute('data-dragging');
      try { if (el.hasPointerCapture(e.pointerId)) el.releasePointerCapture(e.pointerId); } catch (err) {}
      if (e.pointerType === 'touch' || !el.matches(':hover')) rest(); else { lift.to = o.hoverScale; kick(); }
      if (!g.moved) { if (!cancelled && o.flipOnClick) flip(false); else settle(target, 0, false); return; }
      var here = turn.x, velocity = 0, a = g.hist[0], b = g.hist[g.hist.length - 1];
      if (!cancelled && a && b && b.t > a.t && root.performance.now() - b.t < 60) velocity = (b.v - a.v) / (b.t - a.t) * 1000;
      settle(cancelled ? snap(g.base) : clamp(snap(here + velocity * FLING), snap(here) - 180, snap(here) + 180), velocity, false);
    }
    el.addEventListener('pointerup', function (e) { release(e, false); });
    el.addEventListener('pointercancel', function (e) { release(e, true); });
    el.addEventListener('lostpointercapture', function (e) { release(e, true); });
    el.addEventListener('pointerenter', function (e) { if (!reduce && e.pointerType !== 'touch') { lift.to = o.hoverScale; kick(); } });
    el.addEventListener('pointerleave', function () { if (!grip) rest(); });
    el.addEventListener('dragstart', function (e) { e.preventDefault(); });

    sync(); paint();
    return { el: el, flip: flip, get flipped() { return shown; }, spring: turn };
  }
  FlipCard.Spring = Spring;
  root.FlipCard = FlipCard;
  if (typeof module !== 'undefined' && module.exports) module.exports = FlipCard;
})(typeof window !== 'undefined' ? window : globalThis);
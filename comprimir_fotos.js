// Reduce las fotos de public/img (900 px de ancho, JPG ligero).
// Guarda los originales en la carpeta "fotos_originales" por si los necesitas.
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const dir = path.join(__dirname, 'public', 'img');
const backup = path.join(__dirname, 'fotos_originales');

(async () => {
  fs.mkdirSync(backup, { recursive: true });
  let antes = 0, despues = 0;
  for (const f of fs.readdirSync(dir)) {
    if (!/\.jpe?g$/i.test(f)) continue;
    const dest = path.join(dir, f), orig = path.join(backup, f);
    if (!fs.existsSync(orig)) fs.copyFileSync(dest, orig);
    const buf = await sharp(orig).rotate().resize({ width: 900, withoutEnlargement: true })
      .jpeg({ quality: 78, mozjpeg: true }).toBuffer();
    fs.writeFileSync(dest, buf);
    const a = fs.statSync(orig).size, d = buf.length;
    antes += a; despues += d;
    console.log(`${f.padEnd(26)} ${String(Math.round(a / 1024)).padStart(6)} KB -> ${String(Math.round(d / 1024)).padStart(5)} KB`);
  }
  console.log(`\nTotal: ${(antes / 1048576).toFixed(1)} MB -> ${(despues / 1048576).toFixed(1)} MB`);
})();

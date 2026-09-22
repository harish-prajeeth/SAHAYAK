const http = require('http');
const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, 'build', 'web');
const parsedPort = parseInt(process.env.PORT, 10);
const PORT = Number.isFinite(parsedPort) && parsedPort > 0 ? parsedPort : 3000;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript',
  '.mjs': 'application/javascript',
  '.wasm': 'application/wasm',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.css': 'text/css',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.map': 'application/json',
};

http.createServer((req, res) => {
  const urlPath = decodeURIComponent(req.url.split('?')[0].split('#')[0]);
  let filePath = path.join(ROOT, urlPath === '/' ? 'index.html' : urlPath);
  if (!filePath.startsWith(ROOT)) { res.writeHead(403); return res.end(); }

  fs.stat(filePath, (err, st) => {
    if (err || st.isDirectory()) {
      // SPA fallback: unknown routes get the shell
      filePath = path.join(ROOT, 'index.html');
    }
    fs.readFile(filePath, (err2, data) => {
      if (err2) { res.writeHead(404); return res.end('Not found'); }
      res.writeHead(200, {
        'Content-Type': MIME[path.extname(filePath).toLowerCase()] || 'application/octet-stream',
        'Cache-Control': filePath.endsWith('index.html') ? 'no-cache' : 'public, max-age=3600',
      });
      res.end(data);
    });
  });
}).listen(PORT, () => console.log(`Surakshit Mobile (Flutter web) on http://localhost:${PORT}`));

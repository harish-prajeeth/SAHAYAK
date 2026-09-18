const { spawn } = require('child_process');
const path = require('path');

const cwd = path.join(__dirname);
const child = spawn('node.exe', [
  path.join(__dirname, 'node_modules', 'vite', 'bin', 'vite.js'),
  '--port', '5173',
  '--host'
], { cwd, stdio: 'inherit' });

child.on('exit', (code) => process.exit(code));

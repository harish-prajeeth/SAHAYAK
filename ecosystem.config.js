module.exports = {
  apps: [
    {
      name: 'surakshit-api',
      cwd: './backend',
      script: 'src/server.js',
      env: {
        PORT: 5000,
        JWT_SECRET: 'surakshit-super-secure-jwt-secret-2026',
        NODE_ENV: 'development',
      },
    },
    {
      name: 'surakshit-web',
      cwd: './web',
      script: 'serve.py',
      interpreter: 'python',
    },
  ],
};

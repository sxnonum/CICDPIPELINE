const http = require('node:http');

function createApp() {
  return http.createServer((req, res) => {
    res.setHeader('Content-Type', 'application/json');
    if (req.url === '/health') {
      res.writeHead(200);
      return res.end(JSON.stringify({ status: 'ok' }));
    }
    if (req.url === '/') {
      res.writeHead(200);
      return res.end(JSON.stringify({
        message: 'Hej från CI/CD-pipelinen!',
        version: process.env.APP_VERSION || 'dev',
      }));
    }
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Not found' }));
  });
}

module.exports = { createApp };

import { createServer } from 'node:http';
createServer((req, res) => {
  res.setHeader('content-type', 'application/json');
  if (req.url === '/health') return res.end('{"ok":true}');
  if (req.url === '/me' && req.headers.authorization === 'Bearer example-token') return res.end('{"name":"ann"}');
  res.statusCode = 401;
  res.end('{"error":"who are you?"}');
}).listen(4010, () => console.log('http://localhost:4010'));

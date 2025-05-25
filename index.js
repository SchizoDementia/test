const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.static(__dirname));

function isBrowser(req) {
  const accept = req.headers.accept || '';
  return accept.includes('text/html') || accept.includes('application/xhtml+xml');
}

app.get('/api/script', (req, res) => {
  res.type('text/plain');
  return res.send(`print("Hi")`);
});

app.get('/script/api/:scriptName', (req, res) => {
  const scriptName = req.params.scriptName?.toLowerCase();

  if (scriptName === 'test2') {
    res.type('text/plain');
    return res.send(`print("TEST2")`);
  }

  if (scriptName === 'test3') {
    res.type('text/plain');
    return res.send(`print("TEST3")`);
  }

  return res.sendFile(path.join(__dirname, 'index1.html'));
});

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.get('*', (req, res) => {
  if (req.path.toLowerCase().startsWith('/script/api/')) {
    return res.sendFile(path.join(__dirname, 'index1.html'));
  }

  return res.sendFile(path.join(__dirname, 'index2.html'));
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

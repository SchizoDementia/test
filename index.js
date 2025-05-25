const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

// Serve index.html for all static assets (like CSS, JS)
app.use(express.static(__dirname));

// Helper to detect browser visit
function isBrowser(req) {
  const accept = req.headers.accept || '';
  return accept.includes('text/html') || accept.includes('application/xhtml+xml');
}

// Route for /api/script or /CUSTOM
app.get(['/api/script', '/:custom'], (req, res) => {
  const pathRequested = req.path.toLowerCase();
  const custom = req.params.custom?.toLowerCase();

  if (isBrowser(req)) {
    res.sendFile(path.join(__dirname, 'index.html'));
    return;
  }

  // Respond with Luau script only for /api/script or /custom
  if (pathRequested === '/api/script' || custom === 'custom') {
    res.type('text/plain');
    res.send(`-- Loaded from ${req.path}\nprint("Hello from ${req.path}!")`);
  } else {
    res.sendFile(path.join(__dirname, 'index.html'));
  }
});

// Default route for root
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Start server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

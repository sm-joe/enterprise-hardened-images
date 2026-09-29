const http = require("http");

const server = http.createServer((req, res) => {
  if (req.url !== "/") {
    res.writeHead(404);
    res.end();
    return;
  }

  const response = {
    application: "enterprise-hardened-node-test",
    runtime: "node",
    version: process.versions.node,
    uid: process.getuid(),
    gid: process.getgid()
  };

  res.writeHead(200, {
    "Content-Type": "application/json"
  });

  res.end(JSON.stringify(response));
});

server.listen(8080, "0.0.0.0");
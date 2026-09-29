import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/":
            self.send_response(404)
            self.end_headers()
            return

        response = {
            "application": "enterprise-hardened-python-test",
            "runtime": "python",
            "version": "3.13",
            "uid": os.getuid(),
            "gid": os.getgid(),
        }

        payload = json.dumps(response).encode()

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format, *args):
        return


server = HTTPServer(("0.0.0.0", 8080), Handler)
server.serve_forever()
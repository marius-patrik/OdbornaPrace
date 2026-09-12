import http.server
import os
import sys
import threading
import time

PDF_PATH = os.path.abspath("out/main.pdf")
PORT = 3333

HTML_PAGE = """<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Odborná práce – Live PDF Preview</title>
    <style>
        html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background: #525659; }
        iframe { width: 100vw; height: 100vh; border: none; display: block; }
    </style>
</head>
<body>
    <iframe id="pdf-frame" src="/pdf"></iframe>
    <script>
        const evtSource = new EventSource("/events");
        evtSource.onmessage = function(e) {
            if (e.data === "reload") {
                const frame = document.getElementById("pdf-frame");
                frame.src = "/pdf?t=" + Date.now();
            }
        };
        evtSource.onerror = function() {
            setTimeout(() => location.reload(), 2000);
        };
    </script>
</body>
</html>
"""

last_mtime = 0

class PDFHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        global last_mtime
        if self.path == "/" or self.path.startswith("/?"):
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(HTML_PAGE.encode("utf-8"))
        elif self.path.startswith("/pdf"):
            if not os.path.exists(PDF_PATH):
                self.send_error(404, "PDF not found")
                return
            try:
                with open(PDF_PATH, "rb") as f:
                    content = f.read()
                self.send_response(200)
                self.send_header("Content-Type", "application/pdf")
                self.send_header("Content-Length", str(len(content)))
                self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
                self.end_headers()
                self.wfile.write(content)
            except Exception as e:
                self.send_error(500, str(e))
        elif self.path == "/events":
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Cache-Control", "no-cache")
            self.send_header("Connection", "keep-alive")
            self.end_headers()
            
            local_mtime = 0
            if os.path.exists(PDF_PATH):
                local_mtime = os.path.getmtime(PDF_PATH)
            
            try:
                while True:
                    time.sleep(0.5)
                    if os.path.exists(PDF_PATH):
                        current_mtime = os.path.getmtime(PDF_PATH)
                        if current_mtime > local_mtime:
                            local_mtime = current_mtime
                            self.wfile.write(b"data: reload\n\n")
                            self.wfile.flush()
            except (BrokenPipeError, ConnectionResetError):
                pass
        else:
            self.send_error(404)

def run():
    server = http.server.ThreadingHTTPServer(("127.0.0.1", PORT), PDFHandler)
    server.serve_forever()

if __name__ == "__main__":
    run()

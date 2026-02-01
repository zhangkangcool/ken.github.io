#!/usr/bin/env python3
"""
红警2网页版 - 带CORS支持的HTTP服务器
解决浏览器跨域问题
"""

import http.server
import socketserver
from functools import partial

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

PORT = 8000

print("=" * 50)
print("  红警2网页版 - 本地服务器 (支持CORS)")
print("=" * 50)
print()
print(f"✅ 服务器已启动在端口: {PORT}")
print(f"✅ 本地访问: http://localhost:{PORT}")
print()
print("📂 当前目录:", __file__.rsplit('/', 1)[0] or '.')
print()
print("按 Ctrl+C 停止服务器")
print("=" * 50)
print()

Handler = partial(CORSRequestHandler, directory='.')

# 绑定到所有网络接口,允许局域网访问
with socketserver.TCPServer(("0.0.0.0", PORT), Handler) as httpd:
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n\n服务器已停止")

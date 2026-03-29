from http.server import HTTPServer, BaseHTTPRequestHandler
import base64

USER = "admin"
PASS = "password123"

class AuthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        auth = self.headers.get('Authorization', '')

        if auth.startswith('Basic '):
            decoded = base64.b64decode(auth[6:]).decode()

            if decoded == f"{USER}:{PASS}":
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b'ACCESS GRANTED')
                
                return
        
        self.send_response(401)
        self.send_header('WWW-Authenticate', 'Basic realm="Test"')
        self.end_headers()
        self.wfile.write(b'Need auth')

if __name__ == '__main__':
    print("Test server: http://localhost:8080")
    print(f"Login: {USER}, Password: {PASS}")
    HTTPServer(('localhost', 8080), AuthHandler).serve_forever()

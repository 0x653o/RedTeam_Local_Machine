"""
Machine 19: PickleRick — Vulnerable Flask Application
CWE-502: Insecure Deserialization (Python Pickle)

VULNERABILITY: The application stores session data as base64-encoded
pickle objects in cookies. An attacker can craft a malicious pickle
payload that executes arbitrary code when deserialized.

EXPLOIT CHAIN:
1. Grab session cookie from any page
2. Base64 decode → see it's a pickle
3. Craft malicious pickle: os.system('reverse_shell')
4. Base64 encode and replace the cookie
5. Visit any page → server deserializes → RCE as www-data
6. Dump Redis creds → find root SSH key → root

PRIVESC:
- Redis stores an SSH private key at key "backup:ssh_key"
- That key works for root SSH login
"""

from flask import Flask, request, make_response, render_template_string
import pickle
import base64
import os
import json

app = Flask(__name__)

# HTML Templates
INDEX_HTML = """
<!DOCTYPE html>
<html>
<head><title>Notes App</title></head>
<body>
<h1>📝 SecureNotes</h1>
<p>Welcome, {{ username }}!</p>
<form method="POST" action="/note">
    <textarea name="content" rows="4" cols="50" placeholder="Write a note..."></textarea><br>
    <button type="submit">Save Note</button>
</form>
{% if notes %}
<h2>Your Notes</h2>
<ul>
{% for note in notes %}
    <li>{{ note }}</li>
{% endfor %}
</ul>
{% endif %}
<p><a href="/logout">Logout</a></p>
</body>
</html>
"""

LOGIN_HTML = """
<!DOCTYPE html>
<html>
<head><title>Login</title></head>
<body>
<h1>📝 SecureNotes — Login</h1>
<form method="POST" action="/login">
    <input name="username" placeholder="Username"><br><br>
    <input name="password" type="password" placeholder="Password"><br><br>
    <button type="submit">Login</button>
</form>
{% if error %}<p style="color:red">{{ error }}</p>{% endif %}
</body>
</html>
"""

# VULNERABLE: Serialize session with pickle and store in cookie
def create_session(data):
    serialized = pickle.dumps(data)
    return base64.b64encode(serialized).decode('utf-8')

# VULNERABLE: Deserialize session from cookie using pickle.loads()
def load_session(cookie_value):
    try:
        data = base64.b64decode(cookie_value)
        return pickle.loads(data)  # DANGEROUS: arbitrary code execution
    except Exception:
        return None

@app.route('/')
def index():
    session_cookie = request.cookies.get('session')
    if not session_cookie:
        return render_template_string(LOGIN_HTML, error=None)

    session = load_session(session_cookie)
    if not session:
        return render_template_string(LOGIN_HTML, error=None)

    return render_template_string(INDEX_HTML,
        username=session.get('username', 'Unknown'),
        notes=session.get('notes', []))

@app.route('/login', methods=['POST'])
def login():
    username = request.form.get('username', '')
    password = request.form.get('password', '')

    # Hardcoded creds for the "application"
    if username == 'admin' and password == 'admin123':
        session_data = {'username': username, 'notes': [], 'role': 'admin'}
    elif username and password:
        session_data = {'username': username, 'notes': [], 'role': 'user'}
    else:
        return render_template_string(LOGIN_HTML, error='Invalid credentials')

    resp = make_response(render_template_string(INDEX_HTML,
        username=session_data['username'], notes=[]))
    resp.set_cookie('session', create_session(session_data))
    return resp

@app.route('/note', methods=['POST'])
def add_note():
    session_cookie = request.cookies.get('session')
    session = load_session(session_cookie) if session_cookie else None
    if not session:
        return render_template_string(LOGIN_HTML, error='Please login first')

    content = request.form.get('content', '')
    session.setdefault('notes', []).append(content)

    resp = make_response(render_template_string(INDEX_HTML,
        username=session.get('username'), notes=session.get('notes', [])))
    resp.set_cookie('session', create_session(session))
    return resp

@app.route('/logout')
def logout():
    resp = make_response(render_template_string(LOGIN_HTML, error=None))
    resp.delete_cookie('session')
    return resp

@app.route('/health')
def health():
    return json.dumps({'status': 'ok'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)

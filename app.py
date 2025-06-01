from flask import Flask, render_template, request, redirect, send_file, url_for, session
import subprocess, os
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user

app = Flask(__name__)
app.secret_key = 's3cur3-k3y'

login_manager = LoginManager()
login_manager.init_app(app)

VPN_USER_DIR = '/home/ubuntu/users'

# --- Auth Setup ---
class User(UserMixin):
    def __init__(self, id):
        self.id = id

users = {'admin': 'password'}

@login_manager.user_loader
def load_user(user_id):
    return User(user_id)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        u, p = request.form['username'], request.form['password']
        if users.get(u) == p:
            login_user(User(u))
            return redirect('/dashboard')
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect('/login')

# --- VPN Dashboard ---
@app.route('/')
def home():
    return redirect('/login')

@app.route('/dashboard')
@login_required
def dashboard():
    clients = [f[:-5] for f in os.listdir(VPN_USER_DIR) if f.endswith('.ovpn')]
    return render_template('index.html', clients=clients)

@app.route('/add-user', methods=['POST'])
@login_required
def add_user():
    username = request.form['username']
    subprocess.run(['sudo', './scripts/add-client.sh', username])
    return redirect('/dashboard')

@app.route('/revoke-user', methods=['POST'])
@login_required
def revoke_user():
    username = request.form['username']
    subprocess.run(['sudo', './scripts/revoke-client.sh', username])
    return redirect('/dashboard')

@app.route('/download/<username>')
@login_required
def download(username):
    file_path = os.path.join(VPN_USER_DIR, f'{username}.ovpn')
    return send_file(file_path, as_attachment=True)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

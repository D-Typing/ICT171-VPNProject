```
 ____                                        _        _   _             
|  _ \  ___   ___ _   _ _ __ ___   ___ _ __ | |_ __ _| |_(_) ___  _ __  
| | | |/ _ \ / __| | | | '_ ` _ \ / _ \ '_ \| __/ _` | __| |/ _ \| '_ \ 
| |_| | (_) | (__| |_| | | | | | |  __/ | | | || (_| | |_| | (_) | | | |
|____/ \___/ \___|\__,_|_| |_| |_|\___|_| |_|\__\__,_|\__|_|\___/|_| |_|

```
## By Declan Harbord (34633583)

## Site Link: [declanvpn.com](https://declanvpn.com/login)

# Overview #
This is the documentation for the ICT171 Assignment 2 Project. The project is for a VPN client manager that can be used to create files that can then be used with the open source software Open VPN inorder to create a vpn connection. This documentation outlines the complete steps for the creation and usage of the VPN client manager. 

# AWS EC2 Server Setup #

## Use AWS EC2 Server ##
#### Step One: ####
* Go to aws.amazon.com 
* Sign into account and enter EC2 
* Click on Launch and Instance 

#### Step Two: ####
Create an instance with the following specifications 
* Type: Ubuntu 22.04 (latest version) 
* In security groups open ports: 
    * 22 (SSH) 
    * 1194 (UDP) 
    * 5000 (HTTP)
    * 443 (HTTPS)
    * 80 (TCP)
    * These will all have the source 0.0.0.0/0 
* In Key Pair click on ‘Create a New Key Pair’ 
    * Type is RSA 
    * Format is .pem 
* Download and place somewhere secure and accessible 
* The rest can be left as their default configurations

#### Step Three: ####
* Open up a terminal (or whatever equivalent based on the operating system) in the location of the previously created key pair
* Give the key executable permissions
* Insert the following command to externally connect to the server: \
    `ssh -i "KeyName.pem" ubuntu@ec2-3-107-72-28.ap-southeast-2.compute.amazonaws.com`
* Clicking on the connect instance button will show a pasteable version specifically tailored to the server name 

## Install Packages ##

#### Step One: ####
Type the following commands in to install the packages that will be needed: 
```
sudo apt update
sudo apt install openvpn easy-rsa 
sudo apt install python3-flask python3-pip -y
sudo apt install flask-login
```

#### Step Two ####
Set OpenVPN and RSA by using the following commands:
```
wget https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
sudo ./openvpn-install.sh
```

# File Structure #
```
home/ubuntu/
    app.py
    templates/
        login.html
        index.html
    static/
        style.css
    scripts/
        add-client.sh
        revoke-client.sh
    users/
        *.ovpn
```

## Create Directories ##
To create the directories enter the following commands:
```
    mkdir templates
    mkdir static
    mkdir scripts
    mkdir users
```
## Create Files ##
In the following directories create the scripts by entering the following commands:
* templates/
    * `touch login.html`
    * `touch index.html`
* static/
    * `touch style.css`
* scripts/
    * `touch add-client.sh`
    * `touch revoke-client.sh`


# HTML Scripting #

## templates/login.html ##
```
<!--
This file create the site login page. The login page contains an area for the user to 
input a username and a password. It is also connected to a stylesheet for the visuals.
-->
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>VPN Login</title>
        <link rel="stylesheet" href="../static/style.css">
    </head>
    <body class="login-body">
        <div class="login-container">
            <h2>Admin Login</h2>
            <form action="/login" method="POST">
            <input type="text" name="username" placeholder="Username" required />
            <input type="password" name="password" placeholder="Password" required />
            <button type="submit">Login</button>
            </form>
        </div>
    </body>
</html>
```

## templates/index.html ##
```
<!--
This files creates the dashboard for the site. The dashboard contains buttons for creating 
users, revoking users and downloading their files. Along with this it will show the current 
users that are in the system in a list.
-->
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ICT171 - VPN Project</title>
    <link rel="stylesheet" href="../static/style.css">
</head>

<body>
    <header>
        <h1>VPN Project</h1>
        <p>By Declan Harbord (34633583)</p>
    </header>

    <main>
        <section class="card">
            <h2>Add New Client</h2>
            <form action="{{ url_for('add_user') }}" method="POST">
                <input type="text" name="username" placeholder="Client Username" required />
                <button type="submit">Generate Config</button>
            </form>
        </section>

        <section class="card">
            <h2>Revoke Client</h2>
            <form action="{{ url_for('revoke_user') }}" method="POST">
                <input type="text" name="username" placeholder="Client Username" required />
                <button type="submit">Revoke Access</button>
            </form>
        </section>

        <section class="card">
            <h2>Download Client Configs</h2>
            {% if clients %}
                <ul>
                    {% for client in clients %}
                        <li>
                            {{ client }}
                            <a href="{{ url_for('download', username=client) }}">
                                <button type="button">Download</button>
                            </a>
                        </li>
                    {% endfor %}
                </ul>
            {% else %}
                <p>No clients found.</p>
            {% endif %}
        </section>

        <section class="card">
            <h2>VPN Server Status</h2>
            <div class="status">
                <p><strong>Connected Clients:</strong></p>
                <ul id="client-list">
                    {% for client in clients %}
                        <li>{{ client }}</li>
                    {% else %}
                        <li>None</li>
                    {% endfor %}
                </ul>
            </div>
        </section>
    </main>
</body>
</html>

```

# CSS Scripting #

## static/style.css ##
```
/*
This is the stylesheet that is used for the different site pages. It keeps the content
to a blue, black and white color pallete and sizes the text to fill the screen.
*/

  /* General Reset */
  body, h1, h2, p, ul {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }
  
  /* Body Styling */
  body {
    font-family: Arial, sans-serif;
    background: #f4f7fa;
    color: #333;
    padding: 20px;
  }

  header {
    text-align: center;
    padding: 20px 0;
    background-color: #1f2937;
    color: #fff;
    margin-bottom: 30px;
    border-radius: 10px;
  }
  
  main {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 20px;
  }
  
  /* Card Components */
  .card {
    background: #ffffff;
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
  }
  
  .card h2 {
    margin-bottom: 15px;
  }
  
  form input[type="text"],
  form input[type="password"] {
    width: 90%;
    padding: 10px;
    margin: 6px 0 12px;
    border: 1px solid #ccc;
    border-radius: 6px;
  }
  
  a > button {
    background-color: #2563eb;
    color: #fff;
    border: none;
    padding: 10px 16px;
    border-radius: 6px;
    cursor: pointer;
    transition: background-color 0.3s ease;
  }
  
  button:hover {
    background-color: #1e40af;
  }
  
  /* Status Section */
  .status {
    background: #f1f5f9;
    padding: 15px;
    border-radius: 8px;
  }
  
  .status ul {
    list-style: none;
    margin-top: 10px;
  }
  
  /* Login Styling */
  .login-body {
    background-color: #e2e8f0;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100vh;
  }
  
  .login-container {
    background: white;
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 0 15px rgba(0,0,0,0.1);
    width: 300px;
    text-align: center;
  }
```

# Python Scripting #

## app.py ##
```
# This is the main script that handles the site functionality. It contains functions for 
# logging in and out of the site, adding a new user, revoking a current user and
# downloading a user's configuration file. It does this through using the flask package
# to connect the html and bash files together.

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
    subprocess.run(['sudo', '/home/ubuntu/scripts/add-client.sh', username])
    return redirect('/dashboard')

@app.route('/revoke-user', methods=['POST'])
@login_required
def revoke_user():
    username = request.form['username']
    subprocess.run(['sudo', '/home/ubuntu/scripts/revoke-client.sh', username])
    return redirect('/dashboard')

@app.route('/download/<username>')
@login_required
def download(username):
    file_path = os.path.join(VPN_USER_DIR, f'{username}.ovpn')
    return send_file(file_path, as_attachment=True)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

```

# Bash Scripting #

## scripts/add-client.sh ##
```
#!/bin/bash

# Bash script will check if there is a client of that username. If there is not 
# then it will create a .ovpn file with that name based on the client-template file.

USERNAME=$1
cd /etc/openvpn/easy-rsa || exit 1

if [[ -f "pki/issued/$USERNAME.crt" ]]; then
    echo "[!] Certificate for user '$USERNAME' already exists. Overwriting..."
    echo yes | ./easyrsa --batch build-client-full "$USERNAME" nopass
else
    ./easyrsa --batch build-client-full "$USERNAME" nopass
fi

OVPN_FILE="/home/ubuntu/users/$USERNAME.ovpn"
cp /etc/openvpn/client-template.txt "$OVPN_FILE"
cat pki/ca.crt >> "$OVPN_FILE"
cat pki/issued/$USERNAME.crt >> "$OVPN_FILE"
cat pki/private/$USERNAME.key >> "$OVPN_FILE"

echo "[+] Configuration for '$USERNAME' created at $OVPN_FILE"
```

## scripts/revoke-client.sh ##
```
#!/bin/bash

# Bash script will check if there is a client with the inputted 
# username and if so then it will find and delete the client 
# certificate status along with removing them from the system.

USERNAME=$1
cd /etc/openvpn/easy-rsa || exit 1

if [ ! -f "pki/issued/$USERNAME.crt" ]; then
    exit 1
fi

# Revoke cert
echo yes | ./easyrsa revoke "$USERNAME"
./easyrsa gen-crl
cp pki/crl.pem /etc/openvpn/crl.pem

rm -f /home/ubuntu/users/$USERNAME.ovpn

echo "User '$USERNAME' revoked."

```

# Connecting Scripts #

## Set Script Permissions ##
To ensure the scripts run on the site enter the following commands:
```
sudo chown -R ubuntu:ubuntu /home/ubuntu/users
chmod +x scripts/*.sh
```
Allow python to run the bash scripts:
* `sudo visudo`
* Go to the bottom of the script and write this:
    * `ubuntu ALL=(ALL) NOPASSWD: /home/ubuntu/scripts/add-client.sh, /home/ubuntu/scripts/revoke-client.sh`

# Deployment Setup #

#### Step One ####
Install the package gunicorn: `sudo apt install gunicorn`

#### Step Two ####
Enter the following commands: \
`sudo nano /etc/systemd/system/vpnsite.service`

Then paste this text into the file:
```
[Unit]
Description=Gunicorn for VPN Flask app
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu
ExecStart=/usr/bin/gunicorn -w 4 -b 127.0.0.1:8000 app:app

[Install]
WantedBy=multi-user.target
```

#### Step Three ####
Enable the code through the following commands:
```
sudo systemctl daemon-reexec
sudo systemctl enable vpnsite
sudo systemctl start vpnsite
```

#### Step Four ####
Check the site is running with this command:
`sudo systemctl status vpnsite`

**NOTE:** It still will not be able to run yet as it is currently only connected to the loopback address.

# Domain Creation #

#### Step One ####
* Register a domain through the site Route 53 by selectng a name and TLD
* This may take a moment to verify upon checking out
* With this domain create a new hosted zone
* In the domain create two records:
    * The first one will have no subdomain and the value is the public IP address
    * The next has a subdomain of www and is set to alias with an end point set to ‘Alias to another record in the hosted zone
    * The choose the previous record as the endpoint

#### Step Two ####
To set up nginx enter the following commands
```
sudo apt install nginx
sudo nano /etc/nginx/sites-available/vpnsite
```

Paste this text into the file:
```
server {
    listen 80;
    server_name domainname.com www.domainname.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

#### Step Three ####
Enable access through the following commands:
```
sudo ln -s /etc/nginx/sites-available/vpnsite /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

The domain should now be able to be used to enter the site.

# Security Certification #
Add certification through the following commands:
```
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
sudo systemctl enable certbot.timer
```

Provide email and confirmation for the details of the certification and then it should finish.

# Using the Site #
The password for the login in page is:
* Username: admin
* Password: password


Three buttons are present allowing for the creation of a user by typing their name, revoking the user access through inputting their name and downloading their associated configuration file. 

**NOTE:** Typing in usernames and removing them is case sensitive

# .OVPN Usage #
* Go to openvpn’s website and install the vpn client launcher for the specific operating system: https://openvpn.net/client/ 
* When downloaded open and select ‘Upload File’ 
* Drag the .ovpn file from you computer into it to start the vpn \

# Limitations #

Although the site functionality works properly there is currently an issue with the .ovpn files themselves where they are misconfigured making them unable to actually work with the client launcher. Future iterations will improve upon this but as of submission/marking time it is not functional.

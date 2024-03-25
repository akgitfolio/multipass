#!/bin/bash

# Variables
VM_NAME="my-vm"
NETWORK=$(multipass networks | awk 'NR==2{print $1}')
CPUS=2
DISK=8G
MEMORY=2G

# Launch the VM
multipass launch --name $VM_NAME --network $NETWORK --cpus $CPUS --disk $DISK --memory $MEMORY

# Wait for the VM to be ready
echo "Waiting for the $VM_NAME VM to be ready..."
sleep 2

# Install necessary packages inside the VM
multipass exec $VM_NAME -- sudo apt update
multipass exec $VM_NAME -- sudo apt install -y python3 python3-pip python3-venv openssl nginx certbot python3-certbot-nginx

# Create project directory and set up virtual environment
multipass exec $VM_NAME -- bash -c "mkdir flask_project && cd flask_project && python3 -m venv venv"

# Activate virtual environment and install Flask and Certifi
multipass exec $VM_NAME -- bash -c "source flask_project/venv/bin/activate && pip3 install flask certifi"

# Create Flask application
multipass exec $VM_NAME -- bash -c "cat > flask_project/app.py <<EOF
from flask import Flask
import certifi

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from Flask running inside the VM!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, ssl_context=('/etc/letsencrypt/live/yourdomain.com/fullchain.pem', '/etc/letsencrypt/live/yourdomain.com/privkey.pem'))
EOF"

# Get the IP address of the VM
VM_IP=$(multipass info $VM_NAME | grep IPv4 | awk '{print $2}')

echo $VM_IP

# Configure Nginx as a reverse proxy
multipass exec $VM_NAME -- bash -c "cat > /etc/nginx/sites-available/flask_project <<EOF
server {
    listen 80;
    server_name $VM_IP;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}
EOF"

# Enable the Nginx configuration
multipass exec $VM_NAME -- sudo ln -s /etc/nginx/sites-available/flask_project /etc/nginx/sites-enabled/
multipass exec $VM_NAME -- sudo nginx -t
multipass exec $VM_NAME -- sudo systemctl restart nginx

# Obtain SSL certificate from Let's Encrypt
multipass exec $VM_NAME -- sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Run the Flask application
multipass exec $VM_NAME -- bash -c "source flask_project/venv/bin/activate && python3 flask_project/app.py"
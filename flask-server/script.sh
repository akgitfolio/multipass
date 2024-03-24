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
multipass exec $VM_NAME -- sudo apt install -y python3 python3-pip python3-venv

# Create project directory and set up virtual environment
multipass exec $VM_NAME -- bash -c "mkdir flask_project && cd flask_project && python3 -m venv venv"

# Activate virtual environment and install Flask
multipass exec $VM_NAME -- bash -c "source flask_project/venv/bin/activate && pip3 install flask"

# Create Flask application
multipass exec $VM_NAME -- bash -c "cat > flask_project/app.py <<EOF
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from Flask running inside the VM!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
EOF"

# Get the IP address of the VM
VM_IP=$(multipass info $VM_NAME | grep IPv4 | awk '{print $2}')

echo $VM_IP

# Run the Flask application
multipass exec my-vm -- bash -c "source flask_project/venv/bin/activate && python3 flask_project/app.py"




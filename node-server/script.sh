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
multipass exec $VM_NAME -- sudo apt install -y curl

# Install Node.js and npm
multipass exec $VM_NAME -- bash -c "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
multipass exec $VM_NAME -- sudo apt install -y nodejs

# Create project directory and set up HTTP server
multipass exec $VM_NAME -- bash -c "mkdir node_project && cd node_project && npm init -y"

# Create HTTP server application
multipass exec $VM_NAME -- bash -c "cat > node_project/server.js <<EOF
const http = require('http');

const hostname = '0.0.0.0';
const port = 8000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello from Node.js running inside the VM!');
});

server.listen(port, hostname, () => {
  console.log(\`Server running at http://\${hostname}:\${port}/\`);
});
EOF"

# Get the IP address of the VM
VM_IP=$(multipass info $VM_NAME | grep IPv4 | awk '{print $2}')

echo $VM_IP

# Run the HTTP server application
multipass exec $VM_NAME -- bash -c "node node_project/server.js"
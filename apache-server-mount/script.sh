#!/bin/bash

# Variables
VM_NAME="apache-vm"
NETWORK=$(multipass networks | awk 'NR==2{print $1}')
CPUS=2
DISK=8G
MEMORY=2G
SHARED_FOLDER="shared-folder"

# Launch the VM
multipass launch --name $VM_NAME --network $NETWORK --cpus $CPUS --disk $DISK --memory $MEMORY

# Wait for the VM to be ready
echo "Waiting for the $VM_NAME VM to be ready..."
sleep 2

# Mount the shared folder
multipass mount $PWD/$SHARED_FOLDER $VM_NAME:/var/www/html

# Install Apache server inside the VM
multipass exec $VM_NAME -- sudo apt update
multipass exec $VM_NAME -- sudo apt install -y apache2

# Expose Apache server
multipass exec $VM_NAME -- sudo ufw allow 'Apache'
multipass exec $VM_NAME -- sudo systemctl start apache2
multipass exec $VM_NAME -- sudo systemctl enable apache2

# Get the IP address of the VM
VM_IP=$(multipass info $VM_NAME | grep IPv4 | awk '{print $2}')

HOSTS_LINE="$VM_IP $VM_NAME"

# Check if the line already exists in /etc/hosts
if grep -q "$HOSTS_LINE" /etc/hosts; then
    echo "$HOSTS_LINE already exists in /etc/hosts"
else
    # Append the line to /etc/hosts
    echo "Adding $HOSTS_LINE to /etc/hosts"
    echo "$HOSTS_LINE" | sudo tee -a /etc/hosts > /dev/null

    # Verify the line was added
    if grep -q "$HOSTS_LINE" /etc/hosts; then
        echo "$HOSTS_LINE was added successfully"
    else
        echo "Failed to add $HOSTS_LINE, try again!"
    fi
fi

echo "Apache server is installed and running. You can access it at http://$VM_IP, or http://$VM_NAME"
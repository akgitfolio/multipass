#!/bin/bash

# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -C "your_email@example.com" -f ./id_rsa -N ""

# Variables
USER="user"
VM_NAME=$(basename "$PWD")
NETWORK=$(multipass networks | awk 'NR==2{print $1}')
CPUS=2
DISK=8G
MEMORY=2G

# Launch the VM with cloud-init configuration
multipass launch --name $VM_NAME --network $NETWORK --cpus $CPUS --disk $DISK --memory $MEMORY --cloud-init - <<EOF
#cloud-config
users:
  - name: $USER
    groups: sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - $(cat ./id_rsa.pub)
EOF

multipass exec $VM_NAME -- bash -c "echo '$(cat ./id_rsa.pub)' >> ~/.ssh/authorized_keys"

# Wait for the VM to be ready
echo "Waiting for the $VM_NAME VM to be ready..."
sleep 10

# # Get the IP address of the VM
INSTANCE_IP=$(multipass list | grep $VM_NAME | awk '{print $3}')

HOSTS_LINE="$INSTANCE_IP $VM_NAME"

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

# SSH into the VM interactively
ssh -i ./id_rsa $USER@$INSTANCE_IP
# ssh -o StrictHostKeyChecking=no -i ./id_rsa $USER@$INSTANCE_IP
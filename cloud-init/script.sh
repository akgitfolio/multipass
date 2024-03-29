#!/bin/bash

# Variables
VM_NAME="cloud-init-vm"
CLOUD_INIT_FILE="./config.yaml"

# Launch the VM with cloud-init configuration
multipass launch -n $VM_NAME --cloud-init $CLOUD_INIT_FILE

# Wait for the VM to be ready
echo "Waiting for the $VM_NAME VM to be ready..."
sleep 2

# Execute commands inside the VM
multipass exec $VM_NAME -- sudo su -c "cat /var/creation/timestamp.txt"

# Get the IP address of the VM
VM_IP=$(multipass info $VM_NAME | grep IPv4 | awk '{print $2}')

# Output the VM's IP address
echo "VM is running. Access it at http://$VM_IP"
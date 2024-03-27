#!/bin/bash

# Variables
VM_NAME="my-vm"
CPUS=2
DISK=8G
MEMORY=2G

# Launch the VM
multipass launch --name $VM_NAME --cpus $CPUS --disk $DISK --memory $MEMORY

# Wait for the VM to be ready
echo "Waiting for the $VM_NAME VM to be ready..."
sleep 2

# Create a file hello-host.txt and write "Hello from host" into it
echo "Hello from host" > hello-host.txt

# Transfer the file to the VM
multipass transfer hello-host.txt $VM_NAME:/home/ubuntu/hello-host.txt

# Echo the file content from within the VM
multipass exec $VM_NAME -- cat /home/ubuntu/hello-host.txt
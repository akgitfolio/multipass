#!/bin/bash

# multipass set local.privileged-mounts=on

# Variables
VM_NAME="my-vm"
CPUS=2
DISK=8G
MEMORY=2G
SHARED_FOLDER="shared-folder"

# Launch the VM
multipass launch --name $VM_NAME --cpus $CPUS --disk $DISK --memory $MEMORY

# Wait for the VM to be ready
echo "Waiting for the $VM_NAME VM to be ready..."
sleep 2

# Create a shared folder in the current working directory
mkdir -p $SHARED_FOLDER
echo "Hello from host" > $SHARED_FOLDER/hello-host.txt

# Mount the shared folder to the VM
multipass mount $PWD/$SHARED_FOLDER $VM_NAME:/home/ubuntu/$SHARED_FOLDER

# Verify the mount by listing the contents of the shared folder from within the VM
multipass exec $VM_NAME -- ls -l /home/ubuntu/$SHARED_FOLDER

# Echo the content of the file from within the VM
multipass exec $VM_NAME -- cat /home/ubuntu/$SHARED_FOLDER/hello-host.txt

multipass info $VM_NAME
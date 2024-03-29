#!/bin/bash

# List host networks

networksetup -listallhardwareports

ifconfig -a

ipconfig getiflist

# Variables
VM_NAME="my-vm"
NETWORK=$(multipass networks | awk 'NR==2{print $1}')
CPUS=2
DISK=8G
MEMORY=2G

# get the network and store it inside a variable
NETWORK=$(multipass networks | awk 'NR==2{print $1}')

# Launch the VM
multipass launch --name $VM_NAME --network $NETWORK --cpus $CPUS --disk $DISK --memory $MEMORY

# Wait for the VM to be ready
echo "Waiting for the $VM_NAME VM to be ready..."
sleep 2

multipass exec $VM_NAME -- ip a
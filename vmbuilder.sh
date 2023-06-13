#!/bin/bash

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if required parameters are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <resource_group> <vm_name> <vm_size>"
    exit 1
fi

resource_group=$1
vm_name=$2
vm_size=$3

# Create a resource group
az group create --name $resource_group --location eastus

# Create a virtual network
az network vnet create --name myVNet --resource-group $resource_group --subnet-name mySubnet

# Create a public IP address
az network public-ip create --name myPublicIP --resource-group $resource_group --allocation-method Static

# Create a network security group
az network nsg create --name myNetworkSecurityGroup --resource-group $resource_group

# Create a network security group rule to allow SSH traffic
az network nsg rule create --name myNSGRuleSSH --resource-group $resource_group --nsg-name myNetworkSecurityGroup --protocol tcp --direction inbound --priority 1000 --destination-port-range 22

# Create a virtual network interface and associate with the public IP address and network security group
az network nic create --name myNIC --resource-group $resource_group --vnet-name myVNet --subnet mySubnet --public-ip-address myPublicIP --network-security-group myNetworkSecurityGroup

# Create a virtual machine
az vm create --name $vm_name --resource-group $resource_group --nics myNIC --image Canonical:UbuntuServer:20.04-LTS:latest --admin-username azureuser --admin-password Password123 --size $vm_size

# Deallocate the virtual machine
az vm deallocate --name $vm_name --resource-group $resource_group

# Generalize the virtual machine
az vm generalize --name $vm_name --resource-group $resource_group

# Create an image from the generalized virtual machine
az image create --name ubuntu20-image --resource-group $resource_group --source $vm_name

# Delete the virtual machine
az vm delete --name $vm_name --resource-group $resource_group --yes

# Optional: Delete the resource group (uncomment the line below if desired)
# az group delete --name $resource_group --yes

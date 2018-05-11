#!/bin/bash
#
# set -x
linux_ip=$1
org=$2
admin_password=$3
vm_name="itcpVistAUser-$org"
echo "Creating Linux VM"
echo "**Warning** This can take about 5 minutes"
az vm create -g $vm_group_name -n $vm_name --admin-username osehra --admin-password $admin_password --image CentOS --generate-ssh-keys --size Standard_D3_v2 --vnet-name $vnet_name --subnet $subnet_name --private-ip-address $linux_ip --public-ip-address "" > /dev/null

# ipaddr=$(az vm list-ip-addresses -g ${vm_group_name} -n ${vm_name} --query "[].virtualMachine.network.privateIpAddresses[0]|[-1]")
# echo "Linux VM Private IP:"
# echo $ipaddr

# echo "Configuring Linux VM"
# echo "**Warning** This can take about 30 minutes"
# az vm extension set --publisher Microsoft.Azure.Extensions --name CustomScript --version 2.0 --protected-settings ./provision_rhel_machine.json --resource-group ${vm_group_name} --vm-name ${vm_name} > /dev/null
# echo "Getting id of VM Extension"
# extension_id=$(az vm extension list -g ${vm_group_name} --vm-name ${vm_name} --query "[0].id" -otsv)
# echo "Cleaning up Linux VM Extension"
# az vm extension delete --ids $extension_id > /dev/null

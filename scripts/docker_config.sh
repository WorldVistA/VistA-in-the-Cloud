#!/bin/bash
org=$1
vm_name="vitcVistAUser-$org"

echo "Configuring Linux VM"
echo "**Warning** This can take about 30 minutes"
az vm extension set --publisher Microsoft.Azure.Extensions --name CustomScript --version 2.0 --protected-settings ./scripts/provision_rhel_machine.json --resource-group ${vm_group_name} --vm-name ${vm_name} > /dev/null
echo "Getting id of VM Extension"
extension_id=$(az vm extension list -g ${vm_group_name} --vm-name ${vm_name} --query "[0].id" -otsv)
echo "Cleaning up Linux VM Extension"
az vm extension delete --ids $extension_id > /dev/null

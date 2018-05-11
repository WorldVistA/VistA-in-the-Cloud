#!/bin/bash

vm_group_name=$1
vm_name=$2

echo "Updating Windows Remote Desktop Users local group"
echo "**Warning** This can take about 5 minutes"
az vm extension set --publisher Microsoft.Compute --name CustomScriptExtension --version 1.8 --resource-group "${vm_group_name}" --vm-name "${vm_name}" --settings "{'commandToExecute': 'powershell.exe -ExecutionPolicy Unrestricted -Command \"Add-LocalGroupMember -Group \'Remote Desktop Users\' -Member \'OSEHRAVIC\\Domain Users\'\"'}" > /dev/null
echo "Getting id of VM Extension"
extension_id=$(az vm extension list -g ${vm_group_name} --vm-name ${vm_name} --query "[0].id" -otsv)
echo "Cleaning up Update Windows Extension"
az vm extension delete --ids $extension_id > /dev/null

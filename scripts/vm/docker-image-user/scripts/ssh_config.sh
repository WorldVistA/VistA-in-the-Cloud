#!/bin/bash

vm_group_name=$1
vm_name=$2

echo "Updating Linux SSH Config"
echo "**Warning** This can take about 5 minutes"
az vm extension set --publisher Microsoft.Azure.Extensions --name CustomScript --version 2.0 --settings ./scripts/ssh_config.json --resource-group "${vm_group_name}" --vm-name "${vm_name}" > /dev/null
echo "Getting id of VM Extension"
extension_id=$(az vm extension list -g ${vm_group_name} --vm-name ${vm_name} --query "[0].id" -otsv)
echo "Cleaning up Linux SSH Extension"
az vm extension delete --ids $extension_id > /dev/null

#!/bin/bash

vista_machine=$1
org=$2

vm_name_base="vitcWin-${org}"
vm_name=$(echo $vm_name_base | awk '{print substr($0,0,15)}')

FILE_URI="https://raw.githubusercontent.com/OSEHRA/VistA-in-the-Cloud/blob/master/scripts/vm/docker-image-user/ps-scripts/configureWindows.ps1"
echo "Configuring Windows VM"
echo "**Warning** This can take about 15 minutes"
az vm extension set --publisher Microsoft.Compute --name CustomScriptExtension --version 1.8 --settings "{\"fileUris\": [\"$FILE_URI\"], \"commandToExecute\":\"powershell.exe -ExecutionPolicy Unrestricted -File .\\configureWindows.ps1 $vista_machine \"}" --vm-name $win_vm_name --resource-group $vm_group_name > /dev/null
extension_id=$(az vm extension list -g $vm_group_name --vm-name $win_vm_name --query "[0].id" -otsv)
echo "Cleaning up Windows VM Extension"
az vm extension delete --ids $extension_id > /dev/null

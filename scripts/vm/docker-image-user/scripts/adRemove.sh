#!/bin/bash

common_rg=$1
ad_vm_name=$2
org=$3

echo "Removing OU from Domain"
echo "**Warning** This can take about 5 minutes"
az vm extension set --publisher Microsoft.Compute --name CustomScriptExtension --version 1.8 --vm-name $ad_vm_name --resource-group $common_rg --settings "{'commandToExecute':'powershell.exe -ExecutionPolicy Unrestricted -File C:\\scripts\\deleteOrgOU.ps1 \"$org\"'}" > /dev/null
extension_id=$(az vm extension list -g $common_rg --vm-name $ad_vm_name --query "[0].id" -otsv)
echo "Cleaning up OU from Domain Extension"
az vm extension delete --ids $extension_id > /dev/null
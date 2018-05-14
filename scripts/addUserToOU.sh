#!/bin/bash

username=$1
firstName=$2
lastName=$3
org=$4
common_rg=$5
ad_vm_name=$6
userpass=$7

echo "Adding User to OU in Domain"
echo "**Warning** This can take about 5 minutes"
az vm extension set --publisher Microsoft.Compute --name CustomScriptExtension --version 1.8 --vm-name $ad_vm_name --resource-group $common_rg --settings "{'commandToExecute':'powershell.exe -ExecutionPolicy Unrestricted -File C:\\scripts\\createUserInOU.ps1 \"$username\" \"$firstName\" \"$lastName\" \"$org\" \"$userpass\"'}" > /dev/null
extension_id=$(az vm extension list -g $common_rg --vm-name $ad_vm_name --query "[0].id" -otsv)
echo "Cleaning up User to OU Extension"
az vm extension delete --ids $extension_id > /dev/null

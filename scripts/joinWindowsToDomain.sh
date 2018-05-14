#!/bin/bash

vm_group_name=$1
vm_name=$2
ad_password=$3
local_password=$4
org=$5

part1='{"commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"Add-Computer -DomainName osehravic.onmicrosoft.com -LocalCredential $(New-Object System.Management.Automation.PSCredential('"'"'osehra'"'"', $('"'"''
part2=''"'"' | ConvertTo-SecureString -AsPlainText -Force))) -Credential $(New-Object System.Management.Automation.PSCredential('"'"'osehravic.onmicrosoft.com\\VITCAdmin'"'"', $('"'"''
part3=''"'"' | ConvertTo-SecureString -AsPlainText -Force))) -OUPath '"'"'OU=Computers,OU='
part4=',OU=VITC-Machines,DC=osehravic,DC=onmicrosoft,DC=com'"'"' -Force\""}'
psCommand=$part1$local_password$part2$ad_password$part3$org$part4

echo "Joining Windows VM to Domain"
echo "**Warning** This can take about 5 minutes"
az vm extension set --publisher Microsoft.Compute --name CustomScriptExtension --version 1.8 --resource-group "${vm_group_name}" --vm-name "${vm_name}" --settings "$psCommand" > /dev/null
echo "Restarting Windows machine to finish joining the Domain"
az vm restart -g ${vm_group_name} --name ${vm_name} > /dev/null
echo "Getting id of VM Extension"
extension_id=$(az vm extension list -g ${vm_group_name} --vm-name ${vm_name} --query "[0].id" -otsv)
echo "Cleaning up Join Windows to Domain Extension"
az vm extension delete --ids $extension_id > /dev/null

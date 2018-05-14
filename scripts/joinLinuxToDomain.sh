#!/bin/bash

vm_group_name=$1
vm_name=$2
ad_password=$3
org=$4

echo "Joining Linux VM to Domain"
echo "**Warning** This can take about 5 minutes"
az vm extension set --publisher Microsoft.Azure.Extensions --name CustomScript --version 2.0 --settings "{'commandToExecute': 'yum install -y realmd sssd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools ntpdate ntp && echo \"$ad_password\" | realm join --user=VITCAdmin --automatic-id-mapping=no --computer-ou=\"OU=Computers,OU=$org,OU=VITC-Machines\" osehravic.onmicrosoft.com'}" --resource-group "${vm_group_name}" --vm-name "${vm_name}" > /dev/null
echo "Getting id of VM Extension"
extension_id=$(az vm extension list -g ${vm_group_name} --vm-name ${vm_name} --query "[0].id" -otsv)
echo "Cleaning up Linux VM Extension"
az vm extension delete --ids $extension_id > /dev/null

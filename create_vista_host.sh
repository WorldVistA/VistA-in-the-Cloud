#!/bin/bash
#
# set -x
linux_ip=$1
org=$2
admin_password=$3
vm_name="vitcVistAUser-$org"
echo "Creating Linux VM"
echo "**Warning** This can take about 5 minutes"
az vm create -g $vm_group_name -n $vm_name --admin-username osehra --admin-password $admin_password --image CentOS --generate-ssh-keys --size Standard_D3_v2 --vnet-name $vnet_name --subnet $subnet_name --private-ip-address $linux_ip --public-ip-address "" > /dev/null

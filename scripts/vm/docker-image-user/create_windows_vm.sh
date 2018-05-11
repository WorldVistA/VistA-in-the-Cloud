#!/bin/bash
# set -x

admin_password=$1
windows_ip=$2
org=$3

vm_name_base="vitcWin-${org}"
vm_name=$(echo $vm_name_base | awk '{print substr($0,0,15)}')

echo "Creating Windows VM"
echo "**Warning** This can take about 10 minutes"
az vm create -g $vm_group_name -n "$vm_name" --image MicrosoftWindowsDesktop:Windows-10:RS3-Pro:16299.248.1 --size Standard_D3_v2 --admin-username osehra --admin-password $admin_password --vnet-name $vnet_name --subnet $subnet_name --private-ip-address $windows_ip > /dev/null

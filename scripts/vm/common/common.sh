#!/bin/bash
#
set -x
vm_group_name="ITCP-Common-RG"
vm_name="itcpSHAREDResources"
vnet_name="itcpSHAREDVNET"
subnet_name="itcpSHAREDSubnet"
az network vnet create -g $vm_group_name -n $vnet_name --address-prefix 10.6.0.0/16 --subnet-name $subnet_name --subnet-prefix 10.6.0.0/24
az vm create -g $vm_group_name -n $vm_name --image CentOS --generate-ssh-keys --size Standard_D3_v2 --vnet-name $vnet_name --subnet $subnet_name

ipaddr=$(az vm list-ip-addresses -g ${vm_group_name} -n ${vm_name} --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -otsv)
echo $ipaddr

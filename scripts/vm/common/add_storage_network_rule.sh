
#!/bin/bash
#
set -x
vm_group_name="ITCP-Common-RG"
vm_name="itcpSHAREDResources"
vnet_name="itcpSHAREDVNET"
subnet_name="itcpSHAREDSubnet"
storage_group_name="ITCP-Storage-Blobs"
storage_account_name="itcpstorageblobs"
#
# Allow access from the virtual network
az network vnet subnet update --resource-group $vm_group_name --vnet-name $vnet_name --name $subnet_name --service-endpoints "Microsoft.Storage"
subnetid=$(az network vnet subnet show --resource-group $vm_group_name --vnet-name $vnet_name --name $subnet_name --query id --output tsv)
az storage account network-rule add --resource-group $storage_group_name --account-name $storage_account_name --subnet $subnetid

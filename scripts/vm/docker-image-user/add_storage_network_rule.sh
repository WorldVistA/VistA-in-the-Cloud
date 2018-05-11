
#!/bin/bash
#
# set -x
#
# Allow access from the virtual network
echo "Updating Organization VNET with Service Endpoints"
az network vnet subnet update --resource-group $vm_group_name --vnet-name $vnet_name --name $subnet_name --service-endpoints "Microsoft.Storage" > /dev/null
subnetid=$(az network vnet subnet show --resource-group $vm_group_name --vnet-name $vnet_name --name $subnet_name --query id --output tsv)
echo "Adding Organization to Storage Account"
az storage account network-rule add --resource-group $storage_group_name --account-name $storage_account_name --subnet $subnetid > /dev/null

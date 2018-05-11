#!/bin/bash
# This script creates the Storage Account and Container (aka "Bucket")
set -x
#
group_name="ITCP-Storage-Blobs"
AZURE_STORAGE_ACCOUNT="itcpstorageblobs"
container_name="itcp-scripts"

# Create the resource group
az cloud set --name AzureCloud
if [[ $(az account list | grep login) ]]; then
    az login
fi
az group create --name $group_name --location eastus

# Create a locally redundant blob account access from OSEHRA IP address only (for now)
az storage account create --name $AZURE_STORAGE_ACCOUNT --resource-group $group_name --location eastus --sku Standard_LRS --kind BlobStorage --access-tier Cool --https-only true
az storage account network-rule add -g $group_name --account-name $AZURE_STORAGE_ACCOUNT --ip-address 184.185.35.76

# These next two may not be needed.
AZURE_STORAGE_KEY=$(az storage account keys list -g $group_name -n $AZURE_STORAGE_ACCOUNT --query "[0].value" -otsv)
EXPIRE_DATE=$(date -v +5d +%Y-%m-%d)
AZURE_STORAGE_SAS_TOKEN=$(az storage account generate-sas --services b --resource-types o --permissions r --expiry $EXPIRE_DATE --account-name $AZURE_STORAGE_ACCOUNT)

# Create the container (aka "bucket")
az storage container create -n $container_name --account-name $AZURE_STORAGE_ACCOUNT

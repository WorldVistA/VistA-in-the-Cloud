#!/bin/bash
# This script uploads the ITCP Scripts required to deploy Windows
# set -x

group_name="ITCP-Storage-Blobs"
AZURE_STORAGE_ACCOUNT="itcpstorageblobs"
container_name="itcp-scripts"

# Get storage key and SAS token
AZURE_STORAGE_KEY=$(az storage account keys list -g $group_name -n $AZURE_STORAGE_ACCOUNT --query "[0].value" -otsv)
EXPIRE_DATE=$(date -v +5d +%Y-%m-%d)
AZURE_STORAGE_SAS_TOKEN=$(az storage account generate-sas --services b --resource-types o --permissions r --expiry $EXPIRE_DATE --account-name $AZURE_STORAGE_ACCOUNT --query "@" -otsv)

# Get the END URL for our curl test in the end
END_URL=$(az storage account show -g $group_name -n $AZURE_STORAGE_ACCOUNT --query "primaryEndpoints.blob" -otsv)

# Upload ITCP Scripts
for entry in "$(pwd)"/scripts/*
do
    az storage blob upload --account-name $AZURE_STORAGE_ACCOUNT -c $container_name -n $(basename $entry) -f $entry
    curl -I "$END_URL$container_name/$(basename $entry)?$AZURE_STORAGE_SAS_TOKEN"
done

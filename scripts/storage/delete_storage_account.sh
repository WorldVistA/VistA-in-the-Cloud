#!/bin/bash
#
set -x
#
group_name="ITCP-Storage-Blobs"
az group delete --name $group_name # --yes

#!/bin/bash
#
# set -x

export vm_group_name="ITCP-USR-OSEHRA"
# Get the id for Common resources vnet.
ad_vm_name="ITCP-C-DC1"
common_rg="ITCP-Common-RG"
common_vnet="ITCP-Common-RG-vnet"
shared_vnet="itcpSHAREDVNET"
shared_rg="ITCP-Common-RG"
ME=$(basename "$0")

print_usage ()
{
    printf "\n"
    printf "Usage: "
    printf "\t%s [OPTIONS]\n" "$ME"
    printf "Available options\n\n"
    printf "  -h | --help                           : Print help text\n"
    printf "  -a | --ad-name                        : Name of the Domain Controller 1 VM, Default: $ad_vm_name\n"
    printf "  -c | --common-vent <COMMON VNET NAME> : Name of the Common VNET where the Domain Controllers are located, Default: $common_vnet\n"
    printf "  -e | --enterprise                     : Flag to add a sandbox to an Enterprise setup\n"
    printf "  -g | --group <GROUP NAME>             : Name of ResourceGroup (default: $vm_group_name), Default: $vm_group_name\n"
    printf "  -e | --common-rg <COMMON RG NAME>     : Name of the Common Resource group where the Domain Controllers are located, Default: $common_rg\n"
    printf "  -s | --shared-vnet <SHARED VNET NAME> : Name of the Shared VNET Name, Default: $shared_vnet\n"
    printf "  -r | --shared-rg <SHARED RG NAME>     : Name of the Shared Resource Group, Default: $shared_rg\n"
    printf "\n\n"
}

while [[ $1 =~ ^- ]]; do
    case $1 in
        -h  | --help )                 print_usage
                                       exit 0
                                       ;;
        -a  | --ad-name )              shift
                                       ad_vm_name=$1
                                       ;;
        -c  | --common-vnet )          shift
                                       common_vnet=$1
                                       ;;
        -e  | --enterprise )           shift
                                       enterprise=true
                                       ;;
        -g  | --group )                shift
                                       group_name=$1
                                       ;;
        -n  | --common-rg )            shift
                                       common_rg=$1
                                       ;;
        -r  | --shared-rg )            shift
                                       shared_rg=$1
                                       ;;
        -s  | --shared-vnet )          shift
                                       shared_vnet=$1
                                       ;;
        * )                            echo "Unknown option $1"
                                       print_usage
                                       exit 1
    esac
    shift
done

if [[ $group_name ]]; then
    vm_group_name="ITCP-USR-${group_name}"
fi

if [[ $enterprise ]]; then
    # Delete peer from common to us
    echo "Removing peering to Shared VNET"
    az network vnet peering delete -g $shared_rg -n shared-to-consumer-${vm_group_name} --vnet-name $shared_vnet > /dev/null
    echo "Removing peering to Common VNET"
    az network vnet peering delete -g $common_rg -n common-to-consumer-${vm_group_name} --vnet-name $common_vnet > /dev/null

    echo "Removing Organiztion from Domain"
    ./scripts/adRemove.sh $common_rg $ad_vm_name $group_name > /dev/null
fi
echo "Removing resource group"
az group delete --name $vm_group_name --yes > /dev/null

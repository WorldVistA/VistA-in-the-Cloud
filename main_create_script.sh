#!/bin/bash
#
# set -x

# Each Organization needing to use VITC needs a different resource group; so these have to be adjusted.
# Specify -g in order to change it to something else.
export vm_group_name="VITC-USR-OSEHRA"
export vm_subnet_number="7"
ad_vm_name="VITC-C-DC1"
dc_servers="10.1.1.4,10.1.1.5"
common_vnet="VITC-Common-RG-vnet"
common_rg="VITC-Common-RG"
ME=$(basename "$0")

print_usage ()
{
    printf "\n"
    printf "Usage: "
    printf "\t%s [OPTIONS]\n" "$ME"
    printf "Available options\n\n"
    printf "  -h | --help                           : Print help text\n"
    printf "  -a | --ad-name <AD NAME>              : Name of the Domain Controller 1 VM, Default: $ad_vm_name\n"
    printf "  -c | --common-vent <COMMON VNET NAME> : Name of the Common VNET where the Domain Controllers are located, Default: $common_vnet\n"
    printf "  -d | --dc-servers <IP,ADDRESSES>      : Comma seperated list of the domain controller IP's, Default: $dc_servers\n"
    printf "  -e | --enterprise                     : Flag to add a sandbox to an Enterprise setup\n"
    printf "  -g | --group <GROUP NAME>             : Name of organization to generate the Resource Group (No Spaces, replace with a dash `-`), Default: $vm_group_name\n"
    printf "  -p | --password                       : Option to enter a password for Active Directory User\n"
    printf "  -r | --common-rg <COMMON RG NAME>     : Name of the Common Resource group where the Domain Controllers are located, Default: $common_rg\n"
    printf "  -o | --octet <SECOND CIDR OCTET>      : Octet number under 10.X, Default: $vm_subnet_number\n"
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
        -d  | --dc-servers )           shift
                                       dc_servers=$1
                                       ;;
        -e  | --enterprise )           shift
                                       enterprise=true
                                       ;;
        -g  | --group )                shift
                                       group_name=$1
                                       ;;
        -p  | --password )             shift
                                       windows_password=true
                                       ;;
        -r  | --common-rg )            shift
                                       common_rg=$1
                                       ;;
        -o  | --octet )                shift
                                       vm_subnet_number=$1
                                       ;;
        * )                            echo "Unknown option $1"
                                       print_usage
                                       exit 1
    esac
    shift
done

if [[ $group_name ]]; then
    vm_group_name="VITC-USR-${group_name}"
fi

# The reset needs to stay constant
export vnet_name="VITC-USR-${group_name}-vnet"
export subnet_name="VITC-${group_name}-subnet"

# Get required user information
win_password=""
ad_password=""

ask_for_password() {
    echo "**NOTE** Password shall meet the following criteria:"
    echo "Be at least 12 characters long"
    echo "Contain at least 1 Uppercase Letter"
    echo "Contain at least 1 Lowercase Letter"
    echo "Contain at least 1 Number"
    echo "Contain at least 1 Special Character (!@#$%^&*())"
}

validate_win_password() {
    win_password_special=${win_password//[^!@#$%^&*()+=-]}
    if [[ ${#win_password} -ge 12 && "${#win_password_special}" -ge 1 && "$win_password" == *[A-Z]* && "$win_password" == *[a-z]* && "$win_password" == *[0-9]* ]]; then
        echo ""
        echo "Password matches the criteria."
    else
        echo ""
        ask_for_win_password
        validate_win_password
    fi
}

ask_for_win_password() {
    echo ""
    echo "Please enter a password for the Organization Active Directory User"
    ask_for_password
    read -s -p "Organization Active Directory User Password: " win_password
}

validate_ad_password() {
    ad_password_special=${ad_password//[^!@#$%^&*()+=-]}
    if [[ ${#ad_password} -ge 12 && "${#ad_password_special}" -ge 1 && "$ad_password" == *[A-Z]* && "$ad_password" == *[a-z]* && "$ad_password" == *[0-9]* ]]; then
        echo ""
        echo "Password matches the criteria."
    else
        echo ""
        ask_for_ad_password
        validate_ad_password
    fi
}

ask_for_ad_password() {
    echo ""
    echo "Please enter a password for the Active Directory Admin"
    ask_for_password
    read -s -p "AD Admin Password: " ad_password
}

if [[ $windows_password ]]; then
    ask_for_win_password
    validate_win_password
fi

if [[ -z $windows_password ]]; then
    win_password=$(</dev/urandom LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()+=-' | head -c 32)
fi

if [[ $enterprise ]]; then
    ask_for_ad_password
    validate_ad_password

    org_username_default="$group_name.admin"
    read -p "Organization AD Username [$org_username_default]: " org_username
    org_username="${org_username:-$org_username_default}"
    org_firstName_default="Org"
    read -p "Organization AD User First Name [$org_firstName_default]: " org_firstName
    org_firstName="${org_firstName:-$org_firstName_default}"
    org_lastName_default="Admin"
    read -p "Organization AD User Last Name [$org_lastName_default]: " org_lastName
    org_lastName="${org_lastName:-$org_lastName_default}"
fi

# Login to AZ CLI
az cloud set --name AzureCloud
if [ $(az account list &> /dev/null | grep -c id) -eq 0 ]; then
    az login
fi

echo "Creating Organization Resource Group"
az group create --name $vm_group_name --location eastus > /dev/null

# Query for existing 10.7, or supplied vm_subnet_number, vnets
last_vnet=$(az network vnet list --query "[].addressSpace.addressPrefixes[0]|[?contains(@, '10.${vm_subnet_number}')]|[-1]"|cut -d . -f3)

# Check if any vnet with the first two octets exist
if [[ -z $last_vnet ]]; then
    vnet_prefix="10.${vm_subnet_number}.0.0/24"
else
    vnet_prefix=$(echo $last_vnet|awk '{print "10.'${vm_subnet_number}'."$1 + 1".0/24"}')
fi

# Create Network
subnet_prefix=$(echo $(echo ${vnet_prefix}|cut -d / -f1)|awk '{print $1"/26"}')
echo "Creating Organization VNET"
az network vnet create -g $vm_group_name -n $vnet_name --address-prefix $vnet_prefix --subnet-name $subnet_name --subnet-prefix $subnet_prefix > /dev/null

if [[ $enterprise ]]; then
    # Get the id for my vnet.
    vnet_id=$(az network vnet show --resource-group $vm_group_name  --name $vnet_name --query id --out tsv)

    # Get the id for Common resources vnet.
    common_vnet_id=$(az network vnet show --resource-group $common_rg  --name $common_vnet --query id --out tsv)

    # Add peering to VITC-Common-RG to reach AD
    echo "Peering Common RG to Organization RG"
    az network vnet peering create -g $common_rg     -n common-to-consumer-${vm_group_name} --vnet-name $common_vnet --remote-vnet-id $vnet_id        --allow-vnet-access > /dev/null
    echo "Peering Organization RG to Common RG"
    az network vnet peering create -g $vm_group_name -n consumer-to-common-${vm_group_name} --vnet-name $vnet_name   --remote-vnet-id $common_vnet_id --allow-vnet-access > /dev/null

    # Update VNET DNS
    echo "Updated DNS Servers for the VNET"
    az network vnet update -g $vm_group_name -n $vnet_name --dns-servers $(echo ${dc_servers//,/ }) > /dev/null

    # Create Organization OU in AD
    echo "Adding Organization OU in AD"
    echo "**Warning** This can take about 5 minutes"
    az vm extension set --publisher Microsoft.Compute --name CustomScriptExtension --version 1.8 --settings "{'commandToExecute':'powershell.exe -ExecutionPolicy Unrestricted -File C:\\scripts\\createOrgOU.ps1 \"${ad_password}\" \"${group_name}\"'}" --vm-name $ad_vm_name --resource-group $common_rg > /dev/null
    extension_id=$(az vm extension list -g $common_rg --vm-name $ad_vm_name --query "[0].id" -otsv)
    echo "Cleaning up AD Update Extension"
    az vm extension delete --ids $extension_id > /dev/null

    ./scripts/addUserToOU.sh $org_username $org_firstName $org_lastName $group_name $common_rg $ad_vm_name $win_password
fi

# Linux VM
linux_ip=$(echo $(echo ${vnet_prefix}|cut -d . -f1-3)|awk '{print $1".4"}')
./scripts/create_vista_host.sh $linux_ip $group_name $win_password

if [[ $enterprise ]]; then
    # Configure Linux VM SSH settings
    ./scripts/ssh_config.sh $vm_group_name "vitcVistAUser-$group_name"

    # Join Linux VM to Domain
    ./scripts/joinLinuxToDomain.sh $vm_group_name "vitcVistAUser-$group_name" $ad_password $group_name

    # Update Linux VM sssd config
    ./scripts/sssd_config.sh $vm_group_name "vitcVistAUser-$group_name"
fi

# Configure VistA Docker
./scripts/docker_config.sh $group_name

# Create Windows VM
./scripts/create_windows_vm.sh $win_password $(echo $(echo ${vnet_prefix}|cut -d . -f1-3)|awk '{print $1".5"}') $group_name

win_vm_name_base="vitcWin-${group_name}"
win_vm_name=$(echo $win_vm_name_base | awk '{print substr($0,0,15)}')

# Configure Windows VM to talk to VistA
./scripts/configure_windows.sh $linux_ip $group_name

if [[ $enterprise ]]; then
    # Join Windows VM to Domain
    ./scripts/joinWindowsToDomain.sh $vm_group_name $win_vm_name $ad_password $win_password $group_name

    # Update Windows Remote Desktop Users local group to allow non-admins to login
    ./scripts/updateWindowsGroup.sh $vm_group_name $win_vm_name
fi

echo "Setup Summary:"
if [[ $enterprise ]]; then
    echo "Active Directory Username:"
    echo $org_username
else
    echo "Windows User:"
    echo "osehra"
fi
if [[ -z $windows_password ]]; then
    echo "Your windows admin password is: " $win_password
fi
echo "Linux VM Private IP:"
echo $linux_ip
vm_name=$(echo "vitcWin-${group_name}" | awk '{print substr($0,0,15)}')
ipaddr=$(az vm list-ip-addresses -g ${vm_group_name} -n "${vm_name}" --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -otsv)
echo "Windows VM Public IP:"
echo $ipaddr

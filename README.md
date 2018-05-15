INTRODUCTION
------------
The VistA in the Cloud (VitC) environment is a sandbox where third parties - external to VA and OSEHRA - can test their software against a VistA instance operating in a production-like environment with synthetic patients.
Each  VitC sandbox environment will contain:
   * a copy of the VistA Windows clients
   * a copy of VistA on a virtual Linux box
   * Links on the Windows VM desktop for visualizing VistA and a dashboard for dox/tests

Presented here is an outline for establishing an VitC sandbox. There are many areas that need further polishing.

PROCESS OUTLINE
---------------
There is one processes required for establishing a working VitC sandbox, as follow:

 - Create a consumer pair of VMs in a resource group unique to the participating organization:
  * A Windows VM to host the VistA clients;
  * A Linux VM to host the Docker image containing OSEHRA VistA. The resources are key protected (Linux) or password protected (Windows).

SOFTWARE NEEDED
---------------
In order to deploy this sandbox, first install the Azure Command-line Interface (CLI) (https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest). These scripts have been validated for Linux, Windows and MacOS. This step can be done on any laptop from which you can access Azure, if you have local Admin rights.

AZURE ACCOUNT ACCESS NEEDED
---------------------------
The consumer services requires access to the Azure Commercial Cloud (https://portal.azure.us).

Once an account is established, logging in is included as a part of each of the scripts described below.

INDIVIDUAL SETUP
----------------

## CREATE CONSUMER VIRTUAL MACHINES

This step is fully automated. You need to ensure that if any clients are changed, all the SAS URLs are regenerated.

* Run `cd ./scripts/vm/docker-image-user` to change into the required script directory.
* Run `./main_create_script.sh -g <ORG-NAME>` which has the following flags:
  * `-h | --help` Print help text
  * `-a | --ad-name` Name of the Domain Controller 1 VM
  * `-c | --common-vent <COMMON VNET NAME>` Name of the Common VNET where the Domain Controllers are located
  * `-d | --dc-servers <IP,ADDRESSES>` Comma seperated list of the domain controller IP's
  * `-e | --common-rg <COMMON RG NAME>` Name of the Common Resource group where the Domain Controllers are located
  * `-g | --group <GROUP NAME>` Name of Organization to generate the Resource Group (No Spaces, replace with a dash `-`
  * `-p | --password` Option to enter a password for Active Directory User
  * `-r | --shared-rg <SHARED RG NAME>` Name of the Shared Resource Group
  * `-s | --shared-vnet <SHARED VNET NAME>` Name of the Shared VNET Name
  * `-o | --octet <SECOND CIDR OCTET>` Octet number under 10.

* You will be asked to supply the Active Directory password, the Organization AD (Active Directory) Username (Default: <group>.admin), First name (Default: Org), and Last name (Default: Admin).

Once the script is complete, you can access either the Windows or Linux VM's using the Organization AD Username and the generated password, or your supplied password if `-p` was used.

Logging into the Linux machine (the IP is displayed during provisioning) will give you an opportunity to interact with the Docker container. Port 9430 is the XWB Broker port; 8001 is VistALink; 2222 is an ssh into the Docker container; and 57772 is the Caché Portal.

Logging into the Windows machine (the IP is displayed during provisioning) will give you a desktop with all the VistA clients. You will be able to log-in into VistA using CPRS.

## DESTROY CONSUMER VIRTUAL MACHINES

This script will destroy all resources related to a specific organization

* Run `./main_destroy_script.sh -g <ORG-NAME>`. which has the following flags:
  * `-h | --help` Print help text
  * `-a | --ad-name` Name of the Domain Controller 1 VM
  * `-c | --common-vent <COMMON VNET NAME>` Name of the Common VNET where the Domain Controllers are located
  * `-e | --common-rg <COMMON RG NAME>` Name of the Common Resource group where the Domain Controllers are located
  * `-g | --group <GROUP NAME>` Name of ResourceGroup (default: $vm_group_name)
  * `-s | --shared-vnet <SHARED VNET NAME>` Name of the Shared VNET Name
  * `-r | --shared-rg <SHARED RG NAME>` Name of the Shared Resource Group

ENTERPRISE SETUP
----------------

## CREATE INFRASTRUCTURE SERVICES

Depending on your setup, this is either fully automated, or broken up into automated scripts and a manual configuration step.

The required scripts are housed in the [templates](./templates).

### New VNET Setup:

* Navigate to [core-network](./core-network)
* Click on the Deploy Azure button that matches your setup
* Fill in the required fields:
  * `adminUsername` Default: "EnterpriseAdmin"
    * Domain Controller Server/Active Directory Admin username
  * `adminPassword` Default: **NULL**
    * Domain Controller Server/Active Directory Admin password
  * `domainName` Default: "devnet.contoso.us"
    * Active Directory domain name
  * `jumpBoxVmSize` Default: "Standard_D2_v2"
    * Server size for the Windows Jumpbox
  * `DCVmSize` Default: "Standard_D1_v2"
    * Server size for the Domain Controllers
* This will create a new Virtual Network (VNET) with a CIDR block of 10.0.0.0/16 with two subnets 10.0.0.0/24 & 10.0.1.0/24.  The Domain Controller 1 & 2 will be in the first subnet and the Active Directory Forest setup. The Jumpbox will be in the second subnet.  It will also set the VNET DNS servers to 10.0.0.4 and 10.0.0.5.

### Existing VNET Setup:

* Navigate to [existing-network](./existing-network)
* Click on the Deploy Azure button that matches your setup
* Fill in the required fields:
  * `vnetName` Default: "Common"
    * Name of the VNET you want to deploy the stack into
  * `vnetPrimarySubnetPrefix` Default: "10.0.0.0/24"
    * The CIDR block for the first subnet to create within the existing VNET
  * `vnetSecondarySubnetPrefix` Default: "10.0.1.0/24"
    * The CIDR block for the second subnet to create within the existing VNET
  * `adminUsername` Default: "EnterpriseAdmin"
    * Domain Controller Server/Active Directory Admin username
  * `adminPassword` Default: **NULL**
    * Domain Controller Server/Active Directory Admin password
  * `domainName` Default: "devnet.contoso.us"
    * Active Directory domain name
  * `DCVmSize` Default: "Standard_D1_v2"
    * Server size for the Domain Controllers
* This will add two subnets 10.0.0.0/24 & 10.0.1.0/24 to your existing VNET.  The Domain Controller 1 will be launched in the first subnet, and the Active Directory Forest setup.
* In the Azure panel, you have to manually go to Virtual networks -> <vnetName> -> DNS Servers and change it from `Default (Azure-provided)` to `Custom` and add in the Domain Controller IP's.  If you are using the defaults it will be 10.0.0.4 & 10.0.0.5, otherwise it will use the first three octets of your first subnet you created in the existing VNET and the fourth octet will be 4 & 5.  Ex: VNET CIDR: 10.1.0.0/16, first subnet 10.1.5.0/24, second subnet 10.1.5.1/24.  The Domain Controllers will be 10.1.5.4 and 10.1.5.5.
* Once the DNS Servers are updated, you will need to reboot all Virtual Machines in the VNET.  It's required to reboot the Domain Controller 1 server first since it's the main DNS server.
* Navigate to [add-dc-existing](./add-dc-existing)
* Click on the Deploy Azure button that matches your setup
* Fill in the required fields:
  * `vnetName` Default: "Common"
    * Name of the VNET you want to deploy the stack into
  * `vnetPrimarySubnetPrefix` Default: "10.0.0.0/24"
    * The CIDR block for the first subnet to create within the existing VNET
  * `adminUsername` Default: "EnterpriseAdmin"
    * Domain Controller Server/Active Directory Admin username
  * `adminPassword` Default: **NULL**
    * Domain Controller Server/Active Directory Admin password
  * `domainName` Default: "devnet.contoso.us"
    * Active Directory domain name
  * `jumpBoxVmSize` Default: "Standard_D2_v2"
    * Server size for the Windows Jumpbox
  * `DCVmSize` Default: "Standard_D1_v2"
    * Server size for the Domain Controllers
* The fields should use the same information that you supplied in `existing-network` so that the second Domain Controller and the Jumpbox can join the domain and complete the network setup (Since these servers are being joined to the domain they will pick up the VNET DNS settings without needing to reboot).

### Manaul Configuration Requirements

@TODO create PowerShell script to automate this step.

Once you have the Infrastructure setup, you will need do the following manual steps:
* Remote Desktop to the Jumpbox
* From the Jumpbox, Remote Desktop to Domain Controller 1
* From the `Server Manager` dashboard:
  * In the upper right hand coner click `Tools`
  * Select `Active Directory Users and Computers`
* From `Active Directory Users and Computers`:
  * Right click on the domain
  * Choose `New` -> `Organizational Unit`
  * Name: `VITC-Machines`
  * Click `Ok`

## ADD CONSUMER MACHINES
Follow setps in INDIVIDUAL SETUP -> CREATE CONSUMER VIRTUAL MACHINES adding the `-e` flag to indicate enterprise configurations

## DESTROY CONSUMER MACHINES
Follow setps in INDIVIDUAL SETUP -> DESTROY CONSUMER VIRTUAL MACHINES adding the `-e` flag to indicate enterprise configurations

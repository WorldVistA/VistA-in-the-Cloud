Azure Infrastructure as Code (IaC)
----------------------------------

This repository contains basic Azure templates to setup different network configurations depending on requirement.

* core-network is a basic virtual network with two domain controllers in an availability set and a jump box for connecting to the VNET.
* existing-network adds two domain controllers in an availabitly set and a jump box for connecting to an existing VNET.

CREATE INFRASTRUCTURE SERVICES
------------------------------
Depending on your setup, this is either fully automated, or broken up into automated scripts and a manual configuration step.

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

CREDITS
-------

All work is based off scripts from [hansenms](https://github.com/hansenms/iac)
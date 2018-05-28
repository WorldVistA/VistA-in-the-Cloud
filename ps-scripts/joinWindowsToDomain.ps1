Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$AdminUser,
    [Parameter(Mandatory=$True,Position=2)]
    [securestring]$AdminPass,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$DomainName,
    [Parameter(Mandatory=$True,Position=4)]
    [string]$DomainUser,
    [Parameter(Mandatory=$True,Position=5)]
    [securestring]$DomainPass,
    [Parameter(Mandatory=$True,Position=6)]
    [string]$org
)

$secureAdminPass = $($AdminPass | ConvertTo-SecureString -AsPlainText -Force)
$adminCredentials = $(New-Object System.Management.Automation.PSCredential($AdminUser, $secureAdminPass))
$secureDomainPass = $($DomainPass | ConvertTo-SecureString -AsPlainText -Force)
$domainCredentials = $(New-Object System.Management.Automation.PSCredential($DomainName, $secureDomainPass))

Add-Computer -DomainName osehravic.onmicrosoft.com -LocalCredential $adminCredentials -Credential $domainCredentials -OUPath "OU=Computers,OU=$org,OU=VITC-Machines,DC=osehravic,DC=onmicrosoft,DC=com" -Force
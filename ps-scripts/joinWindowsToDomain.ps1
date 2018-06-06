Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$AdminUser,
    [Parameter(Mandatory=$True,Position=2)]
    [securestring]$AdminPass,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$DomainUser,
    [Parameter(Mandatory=$True,Position=4)]
    [securestring]$DomainPass,
    [Parameter(Mandatory=$True,Position=5)]
    [string]$org,
    [Parameter(Mandatory=$True,Position=6)]
    [string]$domain
)

$secureAdminPass = $($AdminPass | ConvertTo-SecureString -AsPlainText -Force)
$adminCredentials = $(New-Object System.Management.Automation.PSCredential($AdminUser, $secureAdminPass))
$secureDomainPass = $($DomainPass | ConvertTo-SecureString -AsPlainText -Force)
$domainCredentials = $(New-Object System.Management.Automation.PSCredential($DomainUser, $secureDomainPass))
$domainPath = $($domain.Split("{.}") | ForEach-Object {"DC=$_"}) -join ","

Add-Computer -DomainName $domain -LocalCredential $adminCredentials -Credential $domainCredentials -OUPath "OU=Computers,OU=$org,OU=VITC-Machines,$domainPath" -Force

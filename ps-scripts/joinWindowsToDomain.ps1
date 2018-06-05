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
    [string]$org,
    [Parameter(Mandatory=$True,Position=7)]
    [string]$domain,
    [Parameter(Mandatory=$True,Position=8)]
    [string]$resourceGroup,
    [Parameter(Mandatory=$True,Position=9)]
    [string]$vmName
)

$secureAdminPass = $($AdminPass | ConvertTo-SecureString -AsPlainText -Force)
$adminCredentials = $(New-Object System.Management.Automation.PSCredential($AdminUser, $secureAdminPass))
$secureDomainPass = $($DomainPass | ConvertTo-SecureString -AsPlainText -Force)
$domainCredentials = $(New-Object System.Management.Automation.PSCredential($DomainName, $secureDomainPass))
$domainPath = $($domain.Split("{.}") | ForEach-Object {"DC=$_"}) -join ","

Add-Computer -DomainName osehravic.onmicrosoft.com -LocalCredential $adminCredentials -Credential $domainCredentials -OUPath "OU=Computers,OU=$org,OU=VITC-Machines,$domainPath" -Force

Remove-AzureRmVMExtension -ResourceGroupName "$resourceGroup" -VMName "$vmName" -Name "CustomScriptExtension"

Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$adUser,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$adPass,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$adCompName,
    [Parameter(Mandatory=$True,Position=4)]
    [string]$org,
    [Parameter(Mandatory=$True,Position=5)]
    [string]$domain
)

$adPassSecure = $adPass | ConvertTo-SecureString -AsPlainText -Force
$adCredential = New-Object System.Management.Automation.PSCredential($adUser, $adPassSecure)
$domainPath = $($domain.Split("{.}") | ForEach-Object {"DC=$_"}) -join ","

$S = New-PSSession -ComputerName "$adCompName"
Import-Module -PSsession $S -Name ActiveDirectory

New-ADOrganizationalUnit -name $org -Path "OU=VITC-Machines,$domainPath" -Credential $adCredential
New-ADOrganizationalUnit -name "Computers" -Path "OU=$org,OU=VITC-Machines,$domainPath" -Credential $adCredential
New-ADOrganizationalUnit -name "Security Groups" -Path "OU=$org,OU=VITC-Machines,$domainPath" -Credential $adCredential
New-ADOrganizationalUnit -name "Users" -Path "OU=$org,OU=VITC-Machines,$domainPath" -Credential $adCredential

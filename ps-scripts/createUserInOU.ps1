Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$username,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$firstName,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$lastName,
    [Parameter(Mandatory=$True,Position=4)]
    [string]$org,
    [Parameter(Mandatory=$True,Position=5)]
    [string]$userPass,
    [Parameter(Mandatory=$True,Position=6)]
    [string]$domain,
    [Parameter(Mandatory=$True,Position=7)]
    [string]$adUser,
    [Parameter(Mandatory=$True,Position=8)]
    [string]$adPass,
    [Parameter(Mandatory=$True,Position=9)]
    [string]$adCompName
)

$userSecurePass = $userPass | ConvertTo-SecureString -AsPlainText -Force
$domainPath = $($domain.Split("{.}") | ForEach-Object {"DC=$_"}) -join ","
$adPassSecure = $adPass | ConvertTo-SecureString -AsPlainText -Force
$adCredential = New-Object System.Management.Automation.PSCredential($adUser, $adPassSecure)

$S = New-PSSession -ComputerName "$adCompName"
Import-Module -PSsession $S -Name ActiveDirectory

New-ADUser -Name "$username" -SamAccountName "$username" -Credential "$adCredential" -GivenName "$firstName" -Surname "$lastName" -DisplayName "$firstName $lastName" -Enabled $true -AccountPassword $userSecurePass -Path "OU=Users,OU=$org,OU=VITC-Machines,$domainPath"

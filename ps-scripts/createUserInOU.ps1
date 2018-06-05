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
    [string]$resourceGroup,
    [Parameter(Mandatory=$True,Position=8)]
    [string]$vmName
)

$userSecurePass = $userPass | ConvertTo-SecureString -AsPlainText -Force
$domainPath = $($domain.Split("{.}") | ForEach-Object {"DC=$_"}) -join ","

New-ADUser -Name "$username" -SamAccountName "$username" -GivenName "$firstName" -Surname "$lastName" -DisplayName "$firstName $lastName" -Enabled $true -AccountPassword $userSecurePass -Path "OU=Users,OU=$org,OU=VITC-Machines,$domainPath"

Remove-AzureRmVMExtension -ResourceGroupName "$resourceGroup" -VMName "$vmName" -Name "CustomScriptExtension"

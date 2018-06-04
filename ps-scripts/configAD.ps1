Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$adUser,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$adPass,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$domain
)

$adPassSecure = $adPass | ConvertTo-SecureString -AsPlainText -Force
# $adUser = "VITCAdmin"
$adCredential = New-Object System.Management.Automation.PSCredential($adUser, $adPassSecure)

# $S = New-PSSession -ComputerName "VITC-C-DC1"
# Import-Module -PSsession $S -Name ActiveDirectory

$domainPath = $($domain.Split("{.}") | ForEach-Object {"DC=$_"}) -join ","


New-ADOrganizationalUnit -name "VITC-Machines" -Path "$domainPath" -Credential $adCredential
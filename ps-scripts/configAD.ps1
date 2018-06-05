Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$adUser,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$adPass,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$domain
)

$adPassSecure = $adPass | ConvertTo-SecureString -AsPlainText -Force
$adCredential = New-Object System.Management.Automation.PSCredential($adUser, $adPassSecure)
$domainPath = $($domain.Split("{.}") | ForEach-Object {"DC=$_"}) -join ","


New-ADOrganizationalUnit -name "VITC-Machines" -Path "$domainPath" -Credential $adCredential

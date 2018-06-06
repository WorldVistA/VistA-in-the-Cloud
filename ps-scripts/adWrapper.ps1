Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$adUser,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$adPass,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$domain,
    [Parameter(Mandatory=$True,Position=4)]
    [string]$org,
    [Parameter(Mandatory=$True,Position=5)]
    [string]$username,
    [Parameter(Mandatory=$True,Position=6)]
    [string]$userPass,
    [Parameter(Mandatory=$True,Position=7)]
    [string]$firstName,
    [Parameter(Mandatory=$True,Position=8)]
    [string]$lastName
)

$configADScript = "configAD.ps1 '$adUser' '$adPass' '$domain'"
$createOrgOUScript = "createOrgOU.ps1 '$adUser' '$adPass' '$org' '$domain'"
$createUserInOUScript = "createUserInOU.ps1 '$username' '$firstName' '$lastName' '$org' '$userPass' '$domain'"
$joinWindowsToDomainScript = "./joinWindowsToDomain.ps1 '$username' '$userPass' '$adUser' '$adPass' '$org' '$domain'"

Invoke-Expression $configADScript
Invoke-Expression $createOrgOUScript
Invoke-Expression $createUserInOUScript
Invoke-Expression $joinWindowsToDomainScript

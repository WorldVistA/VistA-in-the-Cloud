param (
    [Parameter(Mandatory=$True,Position=1)]
    [String]$serverAddress,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$NetBiosName,
    [Parameter(Mandatory=$True,Position=1)]
    [string]$adUser,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$adPass,
    [Parameter(Mandatory=$True,Position=4)]
    [string]$domain,
    [Parameter(Mandatory=$True,Position=5)]
    [string]$org,
    [Parameter(Mandatory=$True,Position=6)]
    [string]$username,
    [Parameter(Mandatory=$True,Position=7)]
    [string]$userPass
)

$configureWindowsSript = "./configurewindows.ps1 '$serverAddress'"
$updateWinGroupScript = "./updateWindowsGroup.ps1 '$NetBiosName'"
$joinWindowsToDomainScript = "./joinWindowsToDomain.ps1 '$username' '$userPass' '$adUser' '$adPass' '$org' '$domain'"

Invoke-Expression $configureWindowsSript
Invoke-Expression $updateWinGroupScript
Invoke-Expression $joinWindowsToDomainScript

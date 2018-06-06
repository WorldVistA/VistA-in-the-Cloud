param (
    [Parameter(Mandatory=$True, Position=1)]
    [String]$serverAddress,
    [Parameter(Mandatory=$True, Position=2)]
    [string]$NetBiosName,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$AdminUser,
    [Parameter(Mandatory=$True,Position=4)]
    [securestring]$AdminPass,
    [Parameter(Mandatory=$True,Position=5)]
    [string]$DomainUser,
    [Parameter(Mandatory=$True,Position=6)]
    [securestring]$DomainPass,
    [Parameter(Mandatory=$True,Position=7)]
    [string]$org,
    [Parameter(Mandatory=$True,Position=8)]
    [string]$domain
)

$configureWindowsSript = "./configurewindows.ps1 '$serverAddress'"
$updateWinGroupScript = "./updateWindowsGroup.ps1 '$NetBiosName'"
$joinWindowsToDomainScript = "./joinWindowsToDomain.ps1 '$AdminUser' '$AdminPass' '$NetBiosName' '$DomainUser' '$DomainPass' '$org' '$domain'"

Invoke-Expression $configureWindowsSript
Invoke-Expression $updateWinGroupScript
Invoke-Expression $joinWindowsToDomainScript
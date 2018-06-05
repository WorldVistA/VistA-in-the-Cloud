Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$Domain
)
Add-LocalGroupMember -Group 'Remote Desktop Users' -Member "$Domain\Domain Users"

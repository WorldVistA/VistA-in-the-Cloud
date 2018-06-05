Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$Domain,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$resourceGroup,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$vmName
)
Add-LocalGroupMember -Group 'Remote Desktop Users' -Member "$Domain\Domain Users"

Remove-AzureRmVMExtension -ResourceGroupName "$resourceGroup" -VMName "$vmName" -Name "CustomScriptExtension"

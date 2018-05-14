Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$org
)

Get-ADOrganizationalUnit -Identity "OU=$org,OU=VITC-Machines,DC=osehravic,DC=onmicrosoft,DC=com" | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru | Remove-ADOrganizationalUnit -Recursive -Confirm:$false
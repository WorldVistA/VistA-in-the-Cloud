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
    [string]$userPass
)

$userSecurePass = $userPass | ConvertTo-SecureString -AsPlainText -Force

New-ADUser -Name "$username" -SamAccountName "$username" -GivenName "$firstName" -Surname "$lastName" -DisplayName "$firstName $lastName" -Enabled $true -AccountPassword $userSecurePass -Path "OU=Users,OU=$org,OU=VITC-Machines,DC=osehravic,DC=onmicrosoft,DC=com"

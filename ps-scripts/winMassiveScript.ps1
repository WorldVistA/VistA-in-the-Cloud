param (
    [Parameter(Mandatory=$True,Position=1)]
    [String]$serverAddress,
    [Parameter(Mandatory=$True,Position=2)]
    [string]$NetBiosName,
    [Parameter(Mandatory=$True,Position=3)]
    [string]$adUser,
    [Parameter(Mandatory=$True,Position=4)]
    [string]$adPass,
    [Parameter(Mandatory=$True,Position=5)]
    [string]$adCompName,
    [Parameter(Mandatory=$True,Position=6)]
    [string]$domain,
    [Parameter(Mandatory=$True,Position=7)]
    [string]$org,
    [Parameter(Mandatory=$True,Position=8)]
    [string]$username,
    [Parameter(Mandatory=$True,Position=9)]
    [string]$userPass,
    [Parameter(Mandatory=$True,Position=10)]
    [string]$firstName,
    [Parameter(Mandatory=$True,Position=11)]
    [string]$lastName
)

# Helper Variables
$adPassSecure = $adPass | ConvertTo-SecureString -AsPlainText -Force
$adCredential = New-Object System.Management.Automation.PSCredential -Argumentlist "$NetBiosName\$adUser", $adPassSecure
$domainPath = $($domain.Split("{.}") | ForEach-Object {"DC=$_"}) -join ","

winrm quickconfig -q
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$adCompName.$domain" -Force

# Import Active Directory to Powershell
$S = New-PSSession -ComputerName "$adCompName.$domain" -Credential $adCredential
Import-Module -PSsession $S -Name ActiveDirectory

# Create Org in OU (createOrgOU.ps1)
New-ADOrganizationalUnit -name $org -Path "OU=VITC-Machines,$domainPath" -Credential $adCredential
New-ADOrganizationalUnit -name "Computers" -Path "OU=$org,OU=VITC-Machines,$domainPath" -Credential $adCredential
New-ADOrganizationalUnit -name "Security Groups" -Path "OU=$org,OU=VITC-Machines,$domainPath" -Credential $adCredential
New-ADOrganizationalUnit -name "Users" -Path "OU=$org,OU=VITC-Machines,$domainPath" -Credential $adCredential

# Create User in OU (createUserInOU.ps1)
$userSecurePass = $userPass | ConvertTo-SecureString -AsPlainText -Force

New-ADUser -Name "$username" -SamAccountName "$username" -Credential $adCredential -GivenName "$firstName" -Surname "$lastName" -DisplayName "$firstName $lastName" -Enabled $true -AccountPassword $userSecurePass -Path "OU=Users,OU=$org,OU=VITC-Machines,$domainPath"

# Join Win VM to Domain (joinWindowsToDomain.ps1)
$adminCredentials = $(New-Object System.Management.Automation.PSCredential($username, $userSecurePass))

Add-Computer -DomainName $domain -LocalCredential $adminCredentials -Credential $adCredential -OUPath "OU=Computers,OU=$org,OU=VITC-Machines,$domainPath" -Force

# Configure Win VM (configureWindows.ps1)
$ErrorActionPreference = "SilentlyContinue"

function shortcut
{
  param($targetFile, $shortcutFile, $shortcutArgs)
  rm -Force $shortcutFile
  $WScriptShell = New-Object -ComObject WScript.Shell
  $shortcut = $WScriptShell.CreateShortcut($shortcutFile)
  $shortcut.TargetPath = $targetFile
  $shortcut.Arguments = $shortcutArgs
  $shortcut.Save()
}

function weblink
{
  param($targeturl, $shortcutFile)
  rm -Force $shortcutFile
  $WScriptShell = New-Object -ComObject WScript.Shell
  $shortcut = $WScriptShell.CreateShortcut($shortcutFile)
  $shortcut.TargetPath = $targeturl
  $shortcut.Save()
}

Invoke-WebRequest -Uri "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.70-installer.msi" -OutFile putty-64bit-0.70-installer.msi
start msiexec -wait -ArgumentList "/x putty-64bit-0.70-installer.msi /q"
start msiexec -wait -ArgumentList "/i putty-64bit-0.70-installer.msi /q"

shortcut "${env:ProgramFiles}\PuTTY\putty.exe" "$env:Public\Desktop\Root Docker.lnk" "-ssh root@$serverAddress -P 2222 -pw docker -C -2"
shortcut "${env:ProgramFiles}\PuTTY\putty.exe" "$env:Public\Desktop\VistA User Access.lnk" "-ssh osehratied@$serverAddress -P 2222 -pw tied -C -2"
shortcut "${env:ProgramFiles}\PuTTY\putty.exe" "$env:Public\Desktop\VistA Programmer Access.lnk" "-ssh osehraprog@$serverAddress -P 2222 -pw prog -C -2"

Invoke-WebRequest -Uri "https://code.osehra.org/files/clients/OSEHRA_VistA/Installer_For_All_Clients/OSEHRA_VISTA_GUI_Demo.msi" -OutFile OSEHRA_VISTA_GUI_Demo.msi
start msiexec -wait -ArgumentList "/i OSEHRA_VISTA_GUI_Demo.msi /q"

rm -Force "$env:Public\Desktop\OSEHRA BCMA Demo.lnk"
rm -Force "$env:Public\Desktop\OSEHRA BCMA Parameters Demo.lnk"
rm -Force "$env:Public\Desktop\OSEHRA CPRS Demo.lnk"
rm -Force "$env:Public\Desktop\OSEHRA Vitals Demo.lnk"
rm -Force "$env:Public\Desktop\OSEHRA Vitals Manager Demo.lnk"

shortcut "C:\Program Files (x86)\VistA\BCMA\BCMA.exe" "$env:Public\Desktop\OSEHRA BCMA.lnk" "CCOW=disable s=$serverAddress p=9430"
shortcut "C:\Program Files (x86)\VistA\BCMA\BCMApar.exe" "$env:Public\Desktop\OSEHRA BCMA Parameters.lnk" "CCOW=disable s=$serverAddress p=9430"
shortcut "C:\Program Files (x86)\VistA\CPRS\CPRSChart.exe" "$env:Public\Desktop\OSEHRA CPRS.lnk" "CCOW=disable s=$serverAddress p=9430"
shortcut "C:\Program Files (x86)\VistA\VITALS\Vitals.exe" "$env:Public\Desktop\OSEHRA Vitals.lnk" "/ccow=disable  /server=$serverAddress /port=9430"
shortcut "C:\Program Files (x86)\VistA\VITALS\VitalsManager.exe" "$env:Public\Desktop\OSEHRA Vitals Manager.lnk" "/ccow=disable  /server=$serverAddress /port=9430"

weblink "https://code.osehra.org/vivian/" $env:Public\Desktop\Vivian.url
weblink "https://code.osehra.org/dox/" $env:Public\Desktop\Dox.url
weblink "http://code.osehra.org/CDash/viewProjects.php" $env:Public\Desktop\CDash.url

Restart-Computer

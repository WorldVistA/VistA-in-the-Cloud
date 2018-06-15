param (
  [Parameter(Mandatory=$True,Position=1)]
  [String]$serverAddress
)

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
weblink "http://$serverAddress" $env:Public\Desktop\Synthea.url

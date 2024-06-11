# Create Desktop Shortcut for Web Launcher
$EdgeShortcutFile = "C:\Users\Public\Desktop\Virtual Office.lnk"

$WScriptShell = New-Object -ComObject WScript.Shell

$EdgeShortcut = $WScriptShell.CreateShortcut($EdgeShortcutFile)
$EdgeShortcut.Arguments = "https://voeast.upicsolutions.org"
$EdgeShortcut.TargetPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$EdgeShortcut.Save()


##Path to HKLM keys for EDGE
$HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
IF (!(Test-Path $HKLMregistryPath)) {
    New-Item -Path $HKLMregistryPath -Force
}

##Enable IE site mode
New-ItemProperty -Path $HKLMregistryPath -Name 'InternetExplorerIntegrationLevel' -Value '1' -PropertyType DWORD -Force


##Site List URL configured to pull sites to open in IE Mode
New-ItemProperty -Path $HKLMregistryPath -Name 'InternetExplorerIntegrationSiteList' -Value 'https://raw.githubusercontent.com/UPICSolutions/EnterpriseModeSiteList/master/sites.xml' -Force | Out-Null


##Path to HKLM keys for Internet Explorer Edge Integration
$HKLMregistryPath2 = 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\EdgeIntegration'


IF (!(Test-Path $HKLMregistryPath2)) {
    New-Item -Path $HKLMregistryPath2 -Force
}


##Enable Internet Explorer Edge Integration
New-ItemProperty -Path $HKLMregistryPath2 -Name 'Supported' -Value '1' -PropertyType DWORD -Force | Out-Null
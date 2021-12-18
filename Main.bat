SET Version=Version 3.34
IF NOT EXIST C:\Apps MD C:\Apps
ECHO. >> C:\Apps\log.txt
ECHO %date% %time% >> C:\Apps\log.txt
ECHO %Version% >> C:\Apps\log.txt
ECHO %time% - Start >> C:\Apps\log.txt

CALL :RenamePC
CALL :UpdateTimeZone
CALL :CheckInternet
CALL :UpdateFirstRun
CALL :UpdateMain
CALL :UpdateScreenConnect
CALL :DisableIPv6
CALL :WiFiPreload
CALL :UnattendUpdate
CALL :Apps
CALL :FileAssociations
CALL :CleanupVMwareDumpFiles
CALL :TruncateLog

ECHO %time% - Finish >> C:\Apps\log.txt
EXIT


::UnattendUpdate--------------------------------------------------------------------
:UnattendUpdate
ECHO %time% - UnattendUpdate - Start >> C:\Apps\log.txt
IF NO EXIST C:\Recovery\AutoApply MD C:\Recovery\AutoApply
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Unattend.xml -O C:\Recovery\AutoApply\Unattend.xml
ECHO %time% - UnattendUpdate - Finish >> C:\Apps\log.txt
EXIT /b


::UpdateFirstRun--------------------------------------------------------------------
:UpdateFirstRun
ECHO %time% - UpdateFirstRun - Start >> C:\Apps\log.txt
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/FirstRun.bat -O C:\Apps\FirstRun.bat
XCOPY C:\Apps\FirstRun.bat C:\Recovery\Scripts\FirstRun.bat /C /R /Y
ECHO %time% - UpdateFirstRun - Finish >> C:\Apps\log.txt
EXIT /b


::UpdateTimeZone--------------------------------------------------------------------
:UpdateTimeZone
ECHO %time% - UpdateTimeZone - Start >> C:\Apps\log.txt
tzutil /s "Eastern Standard Time"
ECHO %time% - UpdateTimeZone - Finish >> C:\Apps\log.txt
EXIT /b


::CheckInternet--------------------------------------------------------------------
:CheckInternet
ECHO %time% - CheckInternet - Start >> C:\Apps\log.txt
SET REPEAT=0
:REPEAT
IF %REPEAT%==5 ECHO %time% - CheckInternet - No Internet >> C:\Apps\log.txt & EXIT
SET /a REPEAT=%REPEAT%+1
ECHO %time% - CheckInternet - Attempt %REPEAT% >> C:\Apps\log.txt
PING google.com -n 1
IF %ERRORLEVEL%==1 TIMEOUT /T 20 & GOTO REPEAT
ECHO %time% - CheckInternet - Finish >> C:\Apps\log.txt
EXIT /b


::UpdateMain-----------------------------------------------------------------------
:UpdateMain
ECHO %time% - UpdateMain - Start >> C:\Apps\log.txt
SCHTASKS /query /TN CFSC_Main
IF %ERRORLEVEL%==1 SCHTASKS /CREATE /SC ONSTART /TN "CFSC_Main" /TR "C:\Apps\Main.bat" /RU SYSTEM /NP /V1 /F
IF %PROCESSOR_ARCHITECTURE%==AMD64 Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat -O C:\Apps\Main.bat
IF %PROCESSOR_ARCHITECTURE%==x86 bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat C:\Apps\Main.bat
FIND "%Version%" C:\Apps\Main.bat
IF %ERRORLEVEL%==0 ECHO %time% - UpdateMain - Updated >> C:\Apps\log.txt & EXIT /b
ECHO %time% - UpdateMain - OutDated - Relaunching >> C:\Apps\log.txt
CALL C:\apps\Main.bat
ECHO %time% - UpdateMain - Finish >> C:\Apps\log.txt
EXIT /b


::UpdateVMMwareClient---------------------------------------------------------------
:UpdateVMwareClient
ECHO %time% - UpdateVMwareClient - Start >> C:\Apps\log.txt
REG ADD "HKLM\SOFTWARE\WOW6432Node\VMware, Inc.\VMware VDM\Client" /T REG_SZ /V ServerURL /D view.childrenfamily.org /f
IF %PROCESSOR_ARCHITECTURE%==x86 GOTO OLD
:NEW
reg query "HKLM\SOFTWARE\WOW6432Node\VMware, Inc.\VMware VDM\Client" /d /f "8.3.0"
IF %errorlevel%==0 ECHO %time% - UpdateVMwareClient - 8.3.0 Installed >> C:\apps\log.txt & EXIT /b
IF NOT EXIST C:\Apps\VMware_8.3.0.exe ECHO %time% - UpdateVMwareClient - Downloading 8.3.0 >> C:\apps\log.txt & Powershell Invoke-WebRequest https://download3.vmware.com/software/view/viewclients/CART22FQ2/VMware-Horizon-Client-2106-8.3.0-18287501.exe -O C:\Apps\VMware_8.3.0.exe
ECHO C:\Apps\vmware_8.3.0.exe /q /i /norestart > C:\Apps\install.bat
ECHO SCHTASKS /DELETE /TN "VMwareUpdate" /F >> C:\Apps\install.bat
ECHO DEL C:\Apps\install.bat /F /Q >> C:\Apps\install.bat
SCHTASKS /CREATE /SC ONSTART /TN "VMwareUpdate" /TR "C:\Apps\install.bat" /RU SYSTEM /NP /V1 /F /Z
tasklist | find "vmware-view.exe"
IF %ERRORLEVEL%==1 SCHTASKS /RUN /TN "VMwareUpdate"
ECHO %time% - UpdateVMwareClient - Installed >> C:\Apps\log.txt
ECHO %time% - UpdateVMwareClient - Finish >> C:\Apps\log.txt
EXIT /b
:OLD 
reg query "HKLM\SOFTWARE\VMware, Inc.\VMware VDM\Client" /d /f "5.5.2"
IF %errorlevel%==0 ECHO %time% - 5.5.2 Installed >> C:\apps\log.txt & EXIT /b
IF NOT EXIST C:\Apps\VMware_5.5.2.exe ECHO ECHO %time% - UpdateVMwareClient - Downloading 5.5.2 >> C:\apps\log.txt & Powershell Invoke-WebRequest https://download3.vmware.com/software/view/viewclients/CART21FQ3/VMware-Horizon-Client-5.5.2-18035009.exe -O C:\Apps\VMware_5.5.2.exe
ECHO C:\Apps\vmware_5.5.2.exe /q /i /norestart > C:\Apps\install.bat
ECHO SCHTASKS /DELETE /TN "VMwareUpdate" /F >> C:\Apps\install.bat
ECHO DEL C:\Apps\install.bat /F /Q >> C:\Apps\install.bat
SCHTASKS /CREATE /SC ONSTART /TN "VMwareUpdate" /TR "C:\Apps\install.bat" /RU SYSTEM /NP /V1 /F /Z
tasklist | find "vmware-view.exe"
IF %ERRORLEVEL%==1 SCHTASKS /RUN /TN "VMwareUpdate"
ECHO %time% - UpdateVMwareClient - Installed >> C:\Apps\log.txt
ECHO %time% - UpdateVMwareClient - Finish >> C:\Apps\log.txt
EXIT /b

::UpdateScreenConnect---------------------------------------------------------------
:UpdateScreenConnect
ECHO %time% - UpdateScreenConnect - Start >> C:\Apps\log.txt
IF NOT EXIST C:\Apps\ScreenConnect_21.13.5058.7951.msi Powershell Invoke-WebRequest https://github.com/Children-and-Family-Services-Center/CFSC_Laptops/raw/main/ScreenConnect_21.13.5058.7951.msi -O C:\Apps\ScreenConnect_21.13.5058.7951.msi & ECHO %time% - UpdateScreenConnect - Downloading >> C:\Apps\log.txt
MSIEXEC.exe /q /i C:\Apps\ScreenConnect_21.13.5058.7951.msi /norestart
ECHO %time% - UpdateScreenConnect - Finish >> C:\Apps\log.txt
EXIT /b

::WiFiPreload-----------------------------------------------------------------------
:WiFiPreload
ECHO %time% - WiFiPreload - Start >> C:\Apps\log.txt
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/WiFi-CFSCPublicPW.xml -O C:\Apps\WiFi-CFSCPublicPW.xml
XCOPY C:\Apps\WiFi-CFSCPublicPW.xml C:\Recovery\Scripts\WiFi-CFSCPublicPW.xml /C /R /Y
netsh wlan show profiles | find "CFSC Public PW"
IF %ERRORLEVEL%==0 ECHO %time% - WiFiPreload - WiFi Already Loaded >> C:\Apps\log.txt & EXIT /b
netsh wlan add profile filename="C:\Apps\WiFi-CFSCPublicPW.xml" interface="Wi-Fi" user=all
ECHO %time% - WiFiPreload - WiFi Loaded >> C:\Apps\log.txt
DEL C:\Apps\WiFI-CFSCPublicPW.xml /F /Q
ECHO %time% - WiFiPreload - Finish >> C:\Apps\log.txt
EXIT /b

::CleanupVMwareDumpFiles------------------------------------------------------------
:CleanupVMwareDumpFiles
ECHO %time% - CleanupVMwareDumpFiles - Start >> C:\Apps\log.txt
RD C:\ProgramData\VMware\VDM /S /Q
RD "C:\Users\United Way\AppData\Local\VMware\VDM" /S /Q
RD "C:\Users\CFSC\AppData\Local\VMware\VDM" /S /Q
DEL %temp%\*.* /F /S /Q
DEL C:\WINDOWS\Temp\*.* /F /S /Q
ECHO %time% - CleanupVMwareDumpFiles - Finish >> C:\Apps\log.txt
EXIT /b

::TruncateLog------------------------------------------------------------
:TruncateLog
ECHO %time% - TruncateLog - Start >> C:\Apps\log.txt
powershell "get-content -tail 100 C:\apps\log.txt" > %temp%\log.txt
MORE %temp%\log.txt > C:\Apps\Log.txt
ECHO %time% - TruncateLog - Finish >> C:\Apps\log.txt
EXIT /b

::DisableIPv6--------------------------------------------------
:DisableIPv6
ECHO %time% - DisableIPv6 - Start >> C:\Apps\log.txt
REG ADD HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters /T REG_DWORD /V DisabledComponents /D 0x11 /F
ECHO %time% - DisableIPv6 - Finish >> C:\Apps\log.txt
EXIT /b

::Apps---------------------------------------------------------
:Apps
::----------------Adobe Reader--------------------------------
ECHO %time% - Apps - Start >> C:\Apps\log.txt
ECHO %time% - Apps - Adobe Reader Installing... >> C:\Apps\log.txt
choco upgrade adobereader -y --install-if-not-installed
ECHO %time% - Apps - Adobe Reader Finished >> C:\Apps\log.txt
::----------------Google Chrome--------------------------------
ECHO %time% - Apps - Google Chrome Installing... >> C:\Apps\log.txt
choco upgrade googlechrome -y --install-if-not-installed
ECHO %time% - Apps - Google Chrome Finished >> C:\Apps\log.txt
::----------------FireFox--------------------------------------
ECHO %time% - Apps - FireFox Installing... >> C:\Apps\log.txt
choco upgrade firefox -y --install-if-not-installed
DEL "C:\Users\Public\Desktop\Firefox.lnk" /f /q
ECHO %time% - Apps - FireFox Finished >> C:\Apps\log.txt
::----------------VLC Media Player-----------------------------
ECHO %time% - Apps - VLC Installing... >> C:\Apps\log.txt
choco upgrade vlc -y --install-if-not-installed
DEL "C:\Users\Public\Desktop\VLC media player.lnk" /f /q
ECHO %time% - Apps - VLC Finished >> C:\Apps\log.txt
::----------------VMware Horizon Client-----------------------
ECHO %time% - Apps - VMware Horizon Client Installing... >> C:\Apps\log.txt
choco upgrade vmware-horizon-client -y --install-if-not-installed
REG ADD "HKLM\SOFTWARE\WOW6432Node\VMware, Inc.\VMware VDM\Client" /T REG_SZ /V ServerURL /D view.childrenfamily.org /f
ECHO %time% - Apps - VMware Horizon Client Finished >> C:\Apps\log.txt
::----------------Zoom Client---------------------------------
ECHO %time% - Apps - Zoom Client Installing... >> C:\Apps\log.txt
choco upgrade Zoom -y --install-if-not-installed
ECHO %time% - Apps - Zoom Client Finished >> C:\Apps\log.txt
::----------------App Configs---------------------------------
ECHO %time% - Apps - App Configs... >> C:\Apps\log.txt
REG ADD HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main /v PreventFirstRunPage /t REG_DWORD /d 1 /f
ECHO %time% - Apps - App Configs Finished >> C:\Apps\log.txt
ECHO %time% - Apps - Finish >> C:\Apps\log.txt
EXIT /b

::FileAssociations--------------------------------------------------------------------
:FileAssociations
ECHO %time% - FileAssociations - Start >> C:\Apps\log.txt
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/AppAssoc.xml -O C:\Apps\AppAssoc.xml
DISM /Online /Export-DefaultAppAssociations:C:\Apps\AppAssoc.xml
ECHO %time% - FileAssociations - Finish >> C:\Apps\log.txt
EXIT /b



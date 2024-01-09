SET Version=Version 3.86
IF NOT EXIST C:\Apps MD C:\Apps
ECHO. >> C:\Apps\log.txt
ECHO %date% %time% >> C:\Apps\log.txt
ECHO %Version% >> C:\Apps\log.txt
ECHO %time% - Start >> C:\Apps\log.txt

CALL :UpdateTimeZone
CALL :SleepSettings
CALL :CheckInternet
CALL :Windows11Block
CALL :LoadVariables
CALL :UpdateMain
CALL :DisableIPv6
CALL :ScreenConnect
CALL :WiFiPreload
CALL :Applications
CALL :FileAssociations
CALL :Recovery
CALL :CleanupVMwareDumpFiles
CALL :TruncateLog

IF EXIST C:\Recovery\AutoApply\Test GOTO test

ECHO %time% - Finish >> C:\Apps\log.txt
EXIT

:test
ECHO %time% - Test Started >> C:\Apps\log.txt
ECHO Test > C:\Users\CFSC\Desktop\Test.txt

IF NOT EXIST C:\Recovery\AutoApply\info.ini Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/info.ini -O C:\Recovery\AutoApply\info.ini
for /f "tokens=1,2 delims==" %%a in (C:\Recovery\AutoApply\info.ini) do (set %%a=%%b)

ECHO %agency% > C:\users\cfsc\desktop\test.txt
ECHO %location% >> C:\users\cfsc\desktop\test.txt

FOR /F "Tokens=*" %%I IN ('powershell "gwmi win32_bios | Select-Object -Expand SerialNumber"') do SET name=%%I
IF %COMPUTERNAME%==%agency%-L-%name:~-7% ECHO %time% - Test Finished - Name Correct >> C:\Apps\log.txt & EXIT /b
WMIC computersystem where caption='%computername%' rename '%agency%-L-%name:~-7%'

FOR /f "tokens=3" %%i in ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /V DefaultUserName') do ( SET CurrentUser=%%i)
WMIC UserAccount where name='%CurrentUser%' rename %agency%
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /T REG_SZ /V DefaultUserName /D %agency% /f

ECHO %time% - Test Finished >> C:\Apps\log.txt
ECHO %time% - Finish >> C:\Apps\log.txt
EXIT

::-----------------------------------------------------------------------------

::LoadVariables---------------------------------------------------------------
:LoadVariables
ECHO %time% - LoadVariables - Start >> C:\Apps\log.txt
IF NOT EXIST C:\Recovery\AutoApply\info.ini Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/info.ini -O C:\Recovery\AutoApply\info.ini
for /f "tokens=1,2 delims==" %%a in (C:\Recovery\AutoApply\info.ini) do (set %%a=%%b)
ECHO %time% - LoadVariables - Finish >> C:\Apps\log.txt
EXIT /b

::Windows11Block---------------------------------------------------------------
:Windows11Block
ECHO %time% - Windows11Block - Start >> C:\Apps\log.txt
REG ADD HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersion /t REG_DWORD /d 1 /f
REG ADD HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersionInfo /t REG_SZ /d 21H2 /f
ECHO %time% - Windows11Block - Finish >> C:\Apps\log.txt
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


::ScreenConnect---------------------------------------------------------------
:ScreenConnect
ECHO %time% - UpdateScreenConnect - Start >> C:\Apps\log.txt
IF NOT EXIST C:\Apps\ScreenConnect.msi Powershell Invoke-WebRequest https://github.com/Children-and-Family-Services-Center/CFSC_Laptops/raw/main/ScreenConnect.msi -O C:\Apps\ScreenConnect.msi & ECHO %time% - UpdateScreenConnect - Downloading >> C:\Apps\log.txt
MSIEXEC.exe /q /i C:\Apps\ScreenConnect.msi /norestart
ECHO %time% - UpdateScreenConnect - Finish >> C:\Apps\log.txt
EXIT /b

::WiFiPreload-----------------------------------------------------------------------
:WiFiPreload
ECHO %time% - WiFiPreload - Start >> C:\Apps\log.txt
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/WiFi-CFSCPublicPW.xml -O C:\Apps\WiFi-CFSCPublicPW.xml
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
DEL C:\Users\CFSC\Desktop\debug.log /F /Q
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

::Applications---------------------------------------------------------
:Applications
ECHO %time% - Apps - Start >> C:\Apps\log.txt
::----------------VMware Horizon Client-----------------------
ECHO %time% - Apps - VMware Horizon Client Installing... >> C:\Apps\log.txt
choco upgrade vmware-horizon-client -y --install-if-not-installed
REG ADD "HKLM\SOFTWARE\WOW6432Node\Policies\VMware, Inc.\VMware VDM\Client" /V ServerURL /T REG_SZ /D horizon.childrenfamily.org /F
REG ADD "HKLM\SOFTWARE\Policies\VMware, Inc.\VMware VDM\Client" /V ServerURL /T REG_SZ /D horizon.childrenfamily.org /F
ECHO %time% - Apps - VMware Horizon Client Finished >> C:\Apps\log.txt
::----------------Google Chrome--------------------------------
ECHO %time% - Apps - Google Chrome Installing... >> C:\Apps\log.txt
choco upgrade googlechrome --ignore-checksums -y --install-if-not-installed
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
::----------------Zoom Client---------------------------------
ECHO %time% - Apps - Zoom Client Installing... >> C:\Apps\log.txt
choco upgrade Zoom -y --install-if-not-installed
ECHO %time% - Apps - Zoom Client Finished >> C:\Apps\log.txt
::----------------Adobe Reader--------------------------------
ECHO %time% - Apps - Adobe Reader Installing... >> C:\Apps\log.txt
choco upgrade adobereader -y --install-if-not-installed
ECHO %time% - Apps - Adobe Reader Finished >> C:\Apps\log.txt
::----------------7Zip--------------------------------
ECHO %time% - Apps - 7Zip Installing... >> C:\Apps\log.txt
choco upgrade 7zip -y --install-if-not-installed
ECHO %time% - Apps - 7Zip Finished >> C:\Apps\log.txt
::----------------ScreenConnect--------------------------------
ECHO %time% - Apps - ScreenConnect Installing... >> C:\Apps\log.txt
IF NOT EXIST C:\Apps\ScreenConnect.msi Powershell Invoke-WebRequest https://childrenfamily.screenconnect.com/Bin/ScreenConnect.ClientSetup.msi?e=Access&y=Guest -O C:\Apps\ScreenConnect.msi & ECHO %time% - UpdateScreenConnect - Downloading >> C:\Apps\log.txt
MSIEXEC.exe /q /i C:\Apps\ScreenConnect.msi /norestart
ECHO %time% - Apps - ScreenConnect Finished >> C:\Apps\log.txt
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

::SleepSettings--------------------------------------------------------------------
:SleepSettings
ECHO %time% - SleepSettings Started >> C:\Apps\log.txt
POWERCFG -Change -monitor-timeout-ac 45
POWERCFG -CHANGE -disk-timeout-ac 0
POWERCFG -CHANGE -standby-timeout-ac 0
POWERCFG -CHANGE -hibernate-timeout-ac 0
POWERCFG -CHANGE -monitor-timeout-dc 15
POWERCFG -CHANGE -disk-timeout-dc 0
POWERCFG -CHANGE -standby-timeout-dc 25
POWERCFG -CHANGE -hibernate-timeout-dc 0
ECHO %time% - SleepSettings Finished >> C:\Apps\log.txt
EXIT /b

::Recovery--------------------------------------------------------------------
:Recovery
ECHO %time% - Recovery Started >> C:\Apps\log.txt
TAKEOWN /R /A /F C:\Recovery /D Y
ICACLS C:\Recovery /setowner SYSTEM /T /C /Q
ICACLS C:\Recovery /reset /T /C /Q
IF NOT EXIST C:\Recovery\AutoApply RD C:\Recovery /s /q & MD C:\Recovery & MD C:\Recovery\AutoApply
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/unattend.xml -O C:\Recovery\AutoApply\unattend.xml
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/WiFi-CFSCPublicPW.xml -O C:\Recovery\AutoApply\WiFi-CFSCPublicPW.xml
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Restore.bat -O C:\Recovery\AutoApply\Restore.bat
ECHO %time% - Recovery Finished >> C:\Apps\log.txt
EXIT /b


SET Version=Version 2.3

:CheckInternet
PING google.com -n 1
IF %ERRORLEVEL%==1 SLEEP 2 & GOTO CheckInternet

::UpdateMain

IF NOT EXIST C:\Apps MD C:\Apps
IF %PROCESSOR_ARCHITECTURE%==AMD64 Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat -O C:\Apps\Main.bat
IF %PROCESSOR_ARCHITECTURE%==x86 bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat C:\Apps\Main.bat
FIND "%Version%" C:\Apps\Main.bat
IF %ERRORLEVEL%==0 GOTO CleanupVMwareClientDumpFiles
ECHO SLEEP 10 > %temp%\temp.bat
ECHO C:\apps\Main.bat >> %temp%\temp.bat
%temp%\temp.bat
EXIT
:CleanupVMwareClientDumpFiles
RD C:\ProgramData\VMware\VDM /S /Q
RD "C:\Users\United Way\AppData\Local\VMware\VDM" /S /Q
RD "C:\Users\CFSC\AppData\Local\VMware\VDM" /S /Q

::WiFi Preload
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/WiFi-CFSCPublicPW.xml -O C:\Apps\WiFi-CFSCPublicPW.xml
CALL netsh wlan add profile filename="C:\Apps\WiFI-CFSCPublicPW.xml" interface="Wi-Fi" user=all
::DEL C:\Apps\WiFI-CFSCPublicPW.xml /F /Q

::UpdateVMwareClient
IF %PROCESSOR_ARCHITECTURE%==x86 GOTO OLD
:NEW
reg query "HKLM\SOFTWARE\WOW6432Node\VMware, Inc.\VMware VDM\Client" /d /f "8.3.0"
IF %errorlevel%==0 EXIT
IF EXIST C:\Apps\VMware_8.3.0.exe GOTO NEWCONTINUE
Powershell Invoke-WebRequest https://download3.vmware.com/software/view/viewclients/CART22FQ2/VMware-Horizon-Client-2106-8.3.0-18287501.exe -O C:\Apps\VMware_8.3.0.exe
:NEWCONTINUE
ECHO C:\Apps\vmware_8.3.0.exe /q /i /norestart > C:\Apps\install.bat
ECHO SCHTASKS /DELETE /TN "VMwareUpdate" /F >> C:\Apps\install.bat
ECHO DEL C:\Apps\install.bat /F /Q >> C:\Apps\install.bat
SCHTASKS /CREATE /SC ONSTART /TN "VMwareUpdate" /TR "C:\Apps\install.bat" /RU SYSTEM /NP /V1 /F /Z
tasklist | find "vmware-view.exe"
IF %ERRORLEVEL%==1 SCHTASKS /RUN /TN "VMwareUpdate"
EXIT
:OLD 
reg query "HKLM\SOFTWARE\VMware, Inc.\VMware VDM\Client" /d /f "5.5.2"
IF %errorlevel%==0 EXIT

IF EXIST C:\Apps\VMware_5.5.2.exe GOTO OLDCONTINUE
Powershell Invoke-WebRequest https://download3.vmware.com/software/view/viewclients/CART21FQ3/VMware-Horizon-Client-5.5.2-18035009.exe -O C:\Apps\VMware_5.5.2.exe
:OLDCONTINUE
ECHO C:\Apps\vmware_5.5.2.exe /q /i /norestart > C:\Apps\install.bat
ECHO SCHTASKS /DELETE /TN "VMwareUpdate" /F >> C:\Apps\install.bat
ECHO DEL C:\Apps\install.bat /F /Q >> C:\Apps\install.bat
SCHTASKS /CREATE /SC ONSTART /TN "VMwareUpdate" /TR "C:\Apps\install.bat" /RU SYSTEM /NP /V1 /F /Z
tasklist | find "vmware-view.exe"
IF %ERRORLEVEL%==1 SCHTASKS /RUN /TN "VMwareUpdate"

SET Version=Version 1.10


::UpdateMain
IF NOT EXIST C:\Apps MD C:\Apps
bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat C:\Apps\Main.bat
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
::bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/WiFi-CFSCPublicPW.xml C:\Apps\WiFi-CFSCPublicPW.xml
::netsh wlan add profile filename="C:\Apps\WiFI-CFSCPublicPW.xml" interface="Wi-Fi" user=all

::UpdateVMwareClient
reg query "HKLM\SOFTWARE\WOW6432Node\VMware, Inc.\VMware VDM\Client" /d /f "8.3.0"
IF %errorlevel%==0 EXIT
reg query "HKLM\SOFTWARE\WOW6432Node\VMware, Inc.\VMware VDM\Client" /d /f "5.5.2"
IF %errorlevel%==0 EXIT
IF %PROCESSOR_ARCHITECTURE%==x86 GOTO OLD
IF EXIST C:\Apps\8.3.0.txt GOTO CONTINUE
:NEW
bitsadmin /transfer VMware /download /priority normal https://download3.vmware.com/software/view/viewclients/CART22FQ2/VMware-Horizon-Client-2106-8.3.0-18287501.exe C:\Apps\VMware.exe
ECHO Downloaded > C:\Apps\8.3.0.txt
GOTO CONTINUE
:OLD 
IF EXIST C:\Apps\5.5.2.txt GOTO CONTINUE
bitsadmin /transfer VMware /download /priority normal https://download3.vmware.com/software/view/viewclients/CART21FQ3/VMware-Horizon-Client-5.5.2-18035009.exe C:\Apps\VMware.exe
ECHO Downloaded > C:\Apps\5.5.2.txt
:CONTINUE
ECHO C:\Apps\vmware.exe /q /i /norestart > C:\Apps\install.bat
ECHO SCHTASKS /DELETE /TN "VMwareUpdate" /F >> C:\Apps\install.bat
ECHO DEL C:\Apps\install.bat /F /Q >> C:\Apps\install.bat
SCHTASKS /CREATE /SC ONSTART /TN "VMwareUpdate" /TR "C:\Apps\install.bat" /RU SYSTEM /NP /V1 /F /Z
tasklist | find "vmware-view.exe"
IF %ERRORLEVEL%==1 SCHTASKS /RUN /TN "VMwareUpdate"

::UpdateMain
IF NOT EXIST C:\Apps MD C:\Apps
bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat C:\Apps\Main.bat

ECHO Main Updated >> C:\log.txt

::CleanupVMwareClientDumpFiles
RD C:\ProgramData\VMware\VDM /S /Q
RD "C:\Users\United Way\AppData\Local\VMware\VDM" /S /Q
RD "C:\Users\CFSC\AppData\Local\VMware\VDM" /S /Q

ECHO DumpClean >> C:\log.txt

::Filters

::UpdateClient
reg query "HKLM\SOFTWARE\WOW6432Node\VMware, Inc.\VMware VDM\Client" /d /f "8.3.0"
IF %errorlevel%==0 EXIT
reg query "HKLM\SOFTWARE\WOW6432Node\VMware, Inc.\VMware VDM\Client" /d /f "5.5.2"
IF %errorlevel%==0 EXIT

ECHO Need Update >> C:\log.txt

reg query "HKLM\SOFTWARE\WOW6432Node\VMware, Inc.\VMware VDM\Client" /v "Version"
IF %errorlevel%==1 GOTO OLD

ECHO New Client Get  >> C:\log.txt
bitsadmin /transfer VMware /download /priority normal https://download3.vmware.com/software/view/viewclients/CART22FQ2/VMware-Horizon-Client-2106-8.3.0-18287501.exe C:\Apps\VMware.exe
ECHO New Client Downloaded >> C:\log.txt
GOTO CONTINUE


:OLD 
ECHO Old Client Get >> C:\log.txt
bitsadmin /transfer VMware /download /priority normal https://download3.vmware.com/software/view/viewclients/CART21FQ3/VMware-Horizon-Client-5.5.2-18035009.exe C:\Apps\VMware.exe
ECHO Old Client Downloaded >> C:\log.txt


:CONTINUE
ECHO C:\Apps\vmware.exe /q /i /norestart > C:\Apps\install.bat
ECHO SCHTASKS /DELETE /TN "VMwareUpdate" /F >> C:\Apps\install.bat
SCHTASKS /CREATE /SC ONSTART /TN "VMwareUpdate" /TR "C:\Apps\install.bat" /RU SYSTEM /NP /V1 /F /Z

ECHO Client Update Task Made >> C:\log.txt
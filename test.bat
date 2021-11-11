SET Version=Version 3.11
IF NOT EXIST C:\Apps MD C:\Apps
ECHO. >> C:\Apps\log.txt
ECHO %date% %time% >> C:\Apps\log.txt
ECHO %Version% >> C:\Apps\log.txt
ECHO %time% - Start >> C:\Apps\log.txt

CALL :CheckInternet
CALL :UpdateMain
CALL :UpdateVMwareClient

ECHO %time% - Finish >> C:\Apps\log.txt
EXIT

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
IF %PROCESSOR_ARCHITECTURE%==AMD64 Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/test.bat -O C:\Apps\test.bat
IF %PROCESSOR_ARCHITECTURE%==x86 bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/test.bat C:\Apps\test.bat
FIND "%Version%" C:\Apps\test.bat
IF %ERRORLEVEL%==0 ECHO %time% - UpdateMain - Updated >> C:\Apps\log.txt & EXIT /b
ECHO %time% - UpdateMain - OutDated - Relaunching >> C:\Apps\log.txt
CALL C:\apps\test.bat
ECHO %time% - UpdateMain - Finish >> C:\Apps\log.txt
EXIT /b


::UpdateVMMwareClient---------------------------------------------------------------
:UpdateVMwareClient
ECHO %time% - UpdateVMwareClient - Start >> C:\Apps\log.txt
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
ECHO %time% - UpdateScreenConnect - Start >> C:\Apps\log.txt
Powershell Invoke-WebRequest https://github.com/Children-and-Family-Services-Center/CFSC_Laptops/raw/main/ScreenConnect.msi -O C:\Apps\ScreenConnect.msi
MSIEXEC.exe /q /i C:\Apps\ScreenConnect.msi /norestart
ECHO %time% - UpdateScreenConnect - Finish >> C:\Apps\log.txt
EXIT /b
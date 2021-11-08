::UpdateMain
::Version 1.0
FIND "Version 1.0" C:\apps\main.bat
IF %ERRORLEVEL%==0 GOTO Updated
bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat C:\Apps\Main.bat
C:\apps\main.bat
ECHO Update >> C:\test.txt
exit
:Updated
::CleanupVMwareClientDumpFiles
RD C:\ProgramData\VMware\VDM /S /Q
RD "C:\Users\United Way\AppData\Local\VMware\VDM" /S /Q
RD "C:\Users\CFSC\AppData\Local\VMware\VDM" /S /Q

::Filters

::Check VMware Client Version
reg query "HKLM\SOFTWARE\WOW6432Node\VMware, Inc.\VMware VDM\Client" /d /f "8.3.0"
IF %errorlevel%==0 EXIT
reg query "HKLM\SOFTWARE\WOW6432Node\VMware, Inc.\VMware VDM\Client" /d /f "5.5.2"
IF %errorlevel%==0 EXIT

ECHO Done >> C:\test.txt
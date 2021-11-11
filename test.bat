SET Version=Version 3.4
IF NOT EXIST C:\Apps MD C:\Apps
ECHO. >> C:\Apps\log.txt
ECHO %date% %time% >> C:\Apps\log.txt
ECHO %Version% >> C:\Apps\log.txt
ECHO Start - %time% >> C:\Apps\log.txt

CALL :CheckInternet
CALL :UpdateMain

ECHO Finish - %time% >> C:\Apps\log.txt
EXIT

::CheckInternet--------------------------------------------------------------------
:CheckInternet
ECHO CheckInternet - %time% - Start >> C:\Apps\log.txt
SET REPEAT=0
:REPEAT
IF %REPEAT%==5 ECHO CheckInternet - No Internet >> C:\Apps\log.txt & EXIT
SET /a REPEAT=%REPEAT%+1
ECHO CheckInternet - Attempt %REPEAT% %time% >> C:\Apps\log.txt
PING google.com -n 1
IF %ERRORLEVEL%==1 TIMEOUT /T 20 & GOTO REPEAT
ECHO CheckInternet - %time% - Finish >> C:\Apps\log.txt
EXIT /b


::UpdateMain-----------------------------------------------------------------------
:UpdateMain
IF %PROCESSOR_ARCHITECTURE%==AMD64 Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/test.bat -O C:\Apps\test.bat
IF %PROCESSOR_ARCHITECTURE%==x86 bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/test.bat C:\Apps\test.bat
FIND "%Version%" C:\Apps\test.bat
IF %ERRORLEVEL%==0 ECHO UpdateMain - Updated >> C:\Apps\log.txt & EXIT /b
ECHO UpdateMain - OutDated - Updating >> C:\Apps\log.txt
ECHO SLEEP 10 > %temp%\temp.bat
ECHO C:\apps\test.bat >> %temp%\temp.bat
ECHO UpdateMain - OutDated - Relaunching >> C:\Apps\log.txt
%temp%\temp.bat
EXIT


::---------------------------------------------------------------------------------

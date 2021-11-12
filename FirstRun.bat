ECHO OFF
set "psCommand=powershell -Command "$pword = read-host 'Administrator Password? ' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set password=%%p
CLS
NET USER Administrator /ACTIVE:YES
NET USER Administrator %password%
IF NOT %USERNAME%==CFSC NET USER CFSC /Add
IF %USERNAME%==CFSC NET LOCALGROUP Administrators CFSC /DELETE
IF NOT EXIST C:\Apps MD C:\Apps
SCHTASKS /query /TN CFSC_Main
IF %ERRORLEVEL%==1 SCHTASKS /CREATE /SC ONSTART /TN "CFSC_Main" /TR "C:\Apps\Main.bat" /RU SYSTEM /NP /V1 /F
IF %PROCESSOR_ARCHITECTURE%==AMD64 Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat -O C:\Apps\Main.bat
IF %PROCESSOR_ARCHITECTURE%==x86 bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat C:\Apps\Main.bat
shutdown /r /t 10
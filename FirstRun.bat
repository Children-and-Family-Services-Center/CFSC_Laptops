set "psCommand=powershell -Command "$pword = read-host 'Administrator Password? ' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set password=%%p
CLS

CALL :RenamePC
CALL :SetupUserAccounts
CALL :InstallApps
CALL :ActivateMainScript
CLS
ECHO Restarting PC, Login as Administrator...
PAUSE
SHUTDOWN -r -t 0
EXIT

::ActivateMainScript-----------------------------------------------------
:ActivateMainScript
IF NOT EXIST C:\Apps MD C:\Apps
IF %PROCESSOR_ARCHITECTURE%==AMD64 Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat -O C:\Apps\Main.bat
IF %PROCESSOR_ARCHITECTURE%==x86 bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat C:\Apps\Main.bat
EXIT /b

::RenamePC-----------------------------------------------------
:RenamePC
ECHO %time% - RenamePC - Start >> C:\Apps\log.txt
FOR /F "Tokens=*" %%I IN ('powershell "gwmi win32_bios | Select-Object -Expand SerialNumber"') do SET name=%%I
IF %COMPUTERNAME%==CFSC-L-%name:~-7% ECHO %time% - RenamePC - Name Correct >> C:\Apps\log.txt & EXIT /b
WMIC computersystem where caption='%computername%' rename 'CFSC-L-%name:~-7%'
ECHO %time% - RenamePC - Finish >> C:\Apps\log.txt
EXIT /b

::SetupUserAccounts-----------------------------------------------------
:SetupUserAccounts
NET USER Administrator /ACTIVE:YES
NET USER Administrator %password%
for /F %%i in ('net localgroup Administrators') do net localgroup Administrators %%i /delete
NET USER CFSC /ADD
NET LOCALGROUP Users CFSC /ADD
WMIC UserAccount WHERE "Name='CFSC'" SET PasswordExpires=FALSE
WMIC UserAccount WHERE "Name='CFSC'" SET PasswordChangeable=FALSE
EXIT /b

::InstallApps-----------------------------------------------------
:InstallApps
POWERSHELL Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Apps.bat -O C:\Apps\Apps.bat
SCHTASKS /CREATE /SC ONCE /TN "CFSC_Apps" /TR "C:\Apps\APPS.bat" /RU SYSTEM /NP /V1 /F
EXIT /b
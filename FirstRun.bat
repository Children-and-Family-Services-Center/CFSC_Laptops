@ECHO OFF
SET Version=Version 2.8
IF NOT EXIST C:\Apps MD C:\Apps
ECHO. >> C:\Apps\log.txt
ECHO %date% %time% >> C:\Apps\log.txt
ECHO %Version% >> C:\Apps\log.txt
ECHO %time% - FirstRun - Start >> C:\Apps\log.txt

set "psCommand=powershell -Command "$pword = read-host 'Administrator Password? ' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set password=%%p
CLS

CALL :CheckInternet
CALL :UpdateFirstRun
CALL :RenamePC
CALL :SetupUserAccounts
CALL :InstallChoco
CALL :ActivateMainScript
CALL :AutoLogon

CLS
IF EXIST C:\Recovery\AutoApply\Test GOTO test
ECHO Restarting PC...
ECHO.
ECHO Watch C:\Apps\Log.txt for status
ECHO %time% - FirstRun - Finish >> C:\Apps\log.txt
ECHO.
TIMEOUT /T 5

SHUTDOWN -r -t 10
EXIT


::Test-----------------------------------------------------------
:test
ECHO %time% - Test Started >> C:\Apps\log.txt



ECHO %time% - Test Finished >> C:\Apps\log.txt
ECHO %time% - Finish >> C:\Apps\log.txt
SHUTDOWN -r -t 10
EXIT

::AutoLogon-----------------------------------------------------
:AutoLogon
ECHO %time% - AutoLogon - Start >> C:\Apps\log.txt
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /T REG_SZ /V DefaultUserName /D CFSC /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /T REG_SZ /V AutoAdminLogon /D 1 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /T REG_SZ /V DefaultPassword /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE" /T REG_DWORD /V DisablePrivacyExperience /D 1 /f
ECHO %time% - AutoLogon - Finish >> C:\Apps\log.txt
EXIT /b

::CheckInternet--------------------------------------------------------------------
:CheckInternet
ECHO %time% - CheckInternet - Start >> C:\Apps\log.txt
SET REPEAT=0
:REPEAT
IF %REPEAT%==5 CLS & ECHO No Internet - Please Connect to Internet and press Enter & PAUSE & SET REPEAT=0
SET /a REPEAT=%REPEAT%+1
PING google.com -n 1
CLS
IF %ERRORLEVEL%==1 ECHO Attempt %REPEAT% - No Internet... & TIMEOUT /T 5 & GOTO REPEAT
CLS
ECHO %time% - CheckInternet - Finished >> C:\Apps\log.txt
EXIT /b

::UpdateFirstRun-----------------------------------------------
:UpdateFirstRun
ECHO %time% - UpdateFirstRun - Start >> C:\Apps\log.txt
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/FirstRun.bat -O C:\Apps\FirstRun.bat
FIND "%Version%" C:\Apps\FirstRun.bat
IF %ERRORLEVEL%==0 ECHO %time% - UpdateFirstRun - Updated >> C:\Apps\log.txt & EXIT /b
ECHO %time% - UpdateFirstRun - OutDated - Relaunching >> C:\Apps\log.txt
CALL C:\apps\FirstRun.bat
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
ECHO %time% - SetupUserAccounts - Start >> C:\Apps\log.txt
NET USER Administrator /ACTIVE:YES
NET USER Administrator %password%
for /F "delims=" %%i in ( 'net localgroup Administrators' ) do ( net localgroup Administrators "%%i" /delete )
NET USER CFSC /ADD
NET LOCALGROUP Users CFSC /ADD
WMIC UserAccount WHERE "Name='CFSC'" SET PasswordExpires=FALSE
WMIC UserAccount WHERE "Name='CFSC'" SET PasswordChangeable=FALSE
ECHO %time% - SetupUserAccounts - Finished >> C:\Apps\log.txt
EXIT /b

::InstallChoco-----------------------------------------------------
:InstallChoco
ECHO %time% - InstallChoco - Start >> C:\Apps\log.txt
POWERSHELL Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
ECHO %time% - InstallChoco - Finished >> C:\Apps\log.txt
EXIT /b

::ActivateMainScript-----------------------------------------------------
:ActivateMainScript
ECHO %time% - ActivateMainScript - Start >> C:\Apps\log.txt
IF NOT EXIST C:\Apps MD C:\Apps
SCHTASKS /CREATE /SC ONSTART /TN "CFSC_Main" /TR "C:\Apps\Main.bat" /RU SYSTEM /NP /V1 /F
IF %PROCESSOR_ARCHITECTURE%==AMD64 Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat -O C:\Apps\Main.bat
IF %PROCESSOR_ARCHITECTURE%==x86 bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat C:\Apps\Main.bat
ECHO %time% - ActivateMainScript - Finished >> C:\Apps\log.txt
EXIT /b

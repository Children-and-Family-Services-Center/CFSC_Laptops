ECHO OFF
::CheckInternet--------------------------------------------------------------------
SET REPEAT=0
:REPEAT
IF %REPEAT%==5 CLS & ECHO No Internet - Please Connect to Internet and press Enter & PAUSE & SET REPEAT=0
SET /a REPEAT=%REPEAT%+1
PING google.com -n 1
CLS
IF %ERRORLEVEL%==1 ECHO Attempt %REPEAT% - No Internet... & TIMEOUT /T 5 & GOTO REPEAT
CLS
ECHO We Have Internet!
PAUSE
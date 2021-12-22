::CheckInternet--------------------------------------------------------------------
SET REPEAT=0
:REPEAT
IF %REPEAT%==5 CLS & ECHO No Internet - Please Connect to Internet and press Enter & PAUSE & SET REPEAT=0
SET /a REPEAT=%REPEAT%+1
PING google.com -n 1
IF %ERRORLEVEL%==1 TIMEOUT /T 20 & GOTO REPEAT
CLS
ECHO We Have Internet!
PAUSE
choco upgrade adobereader -y --install-if-not-installed
choco upgrade googlechrome -y --install-if-not-installed
choco upgrade firefox -y --install-if-not-installed
choco upgrade vlc -y --install-if-not-installed
choco upgrade vmware-horizon-client -y --install-if-not-installed
DEL "C:\Users\Public\Desktop\Firefox.lnk" /f /q
DEL "C:\Users\Public\Desktop\VLC media player.lnk" /f /q
SCHTASKS /CREATE /SC ONSTART /TN "CFSC_Main" /TR "C:\Apps\Main.bat" /RU SYSTEM /NP /V1 /F
SCHTASKS /RUN /TN "CFSC_Main"
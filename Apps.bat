choco install adobereader -y
choco install googlechrome -y
choco install firefox -y
choco install vlc -y
choco install vmware-horizon-client -y
DEL "C:\Users\Public\Desktop\Firefox.lnk" /f /q
DEL "C:\Users\Public\Desktop\VLC media player.lnk" /f /q
SCHTASKS /CREATE /SC ONSTART /TN "CFSC_Main" /TR "C:\Apps\Main.bat" /RU SYSTEM /NP /V1 /F

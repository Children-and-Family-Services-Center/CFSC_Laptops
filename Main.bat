::UpdateMain
IF NOT EXIST C:\Apps MD C:\Apps
bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/Main.bat C:\Apps\Main.bat

ECHO Main Updated >> C:\log.txt

::CleanupVMwareClientDumpFiles
RD C:\ProgramData\VMware\VDM /S /Q
RD "C:\Users\United Way\AppData\Local\VMware\VDM" /S /Q
RD "C:\Users\CFSC\AppData\Local\VMware\VDM" /S /Q

ECHO DumpClean >> C:\log.txt

::Filters

::Scripts
bitsadmin /transfer VMware /download /priority normal https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/VMwareUpdate.bat C:\Apps\UpdateVMware.bat

ECHO CallingClientUpdate >> C:\log.txt

SCHTASKS /CREATE /SC ONCE /TN "VMwareUpdate" /TR "C:\Apps\VMwareUpdate.bat" /RU SYSTEM /NP /V1 /F
SCHTASKS /RUN /TN "VMwareUpdate"


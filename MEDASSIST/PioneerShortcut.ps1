
# PowerShell login script for PioneerRx shortcut

# --- Config ---
$ShortcutName = "PioneerRx.lnk"
$DownloadUrl  = "https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/refs/heads/main/MEDASSIST/PioneerRx.lnk"   # <-- replace with your URL

# --- Paths ---
$DesktopPath  = [Environment]::GetFolderPath("Desktop")
$OneDriveDesktopPath = Join-Path $env:OneDrive "Desktop"

# --- Determine if Desktop is redirected to OneDrive ---
$DesktopIsInOneDrive = $false
if ($env:OneDrive -and (Test-Path $OneDriveDesktopPath)) {
    if ($DesktopPath.TrimEnd('\') -ieq $OneDriveDesktopPath.TrimEnd('\')) {
        $DesktopIsInOneDrive = $true
    }
}

# --- Check for existing shortcut ---
$ShortcutPath = Join-Path $DesktopPath $ShortcutName
if (-not (Test-Path $ShortcutPath)) {
    try {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $ShortcutPath -UseBasicParsing
        Write-Output "Downloaded $ShortcutName to $ShortcutPath"
    }
    catch {
        Write-Error "Failed to download $ShortcutName from $DownloadUrl. Error: $_"
    }
}
else {
    Write-Output "$ShortcutName already exists at $ShortcutPath"
}


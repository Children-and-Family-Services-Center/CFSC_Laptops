# Script for syncing sharepoint library for a user. 
# This script is intended to be run from the user's context, not as system or admin.
#
# "Automating the Syncing of Sharepoint team site libraries" by "Intune Training" channel
# Go to "region sharepoint sync" in this script and replace the variables inside the Params block
# Stolen from https://www.youtube.com/watch?v=Zoac9lbUuG0
#
# Corey Cutler and Ian Cox
# Ascend Nonprofit Solutions
# 2/10/24

# Instructions:
#
# Find + Replace variables in the "params" section


# Loop until OneDrive process starts
while ($true) {
    $onedriveProcess = Get-Process "OneDrive" -ErrorAction SilentlyContinue

    if ($onedriveProcess -ne $null) {
        Write-Output "OneDrive is running now."
        break
    } else {
        Write-Output "OneDrive is not running yet. Waiting..."
    }

    # Wait for 1 second before checking again
    Start-Sleep -Seconds 1
}

# Continue with the rest of the script
Write-Output "Continue with the rest of the script..."


$registryPath = 'HKCU:\SOFTWARE\Microsoft\OneDrive'
$ValueName = 'ClientEverSignedIn'
$TargetValue = 1  # Set the target value to 1
 
# Loop until the registry value is found
while ($true) {
    # Use Get-ItemProperty to retrieve the specific registry value
    $registryValue = Get-ItemProperty -Path $registryPath -Name $ValueName | Select-Object -ExpandProperty $ValueName
 
    # Check if the registry value equals 1
    if ($registryValue -eq $TargetValue) {
        Write-Host "Registry value found: $registryValue"
        break  # Exit the loop when the value is found
    }
 
    # Display a message and wait before checking again
    Write-Host "Registry value not 1 yet. Waiting..."
    Start-Sleep -Seconds 5  # Adjust the sleep duration as needed
}
 
# Continue with the rest of your script or actions
Write-Output "Continue with the rest of the script..."

# # Define the path to the user's OneDrive folder
# $OneDrivePath = "$env:userprofile\OneDrive"

# # Loop until OneDrive folder exists
# while ($true) {
#     $onedrivePathExists = Test-Path -Path $OneDrivePath

#     if ($onedriveProcess -ne $null) {
#         Write-Output "OneDrive synchronization has started for the user."
#         break
#     } else {
#         Write-Output "OneDrive synchronization has not started yet for the user."
#     }

#     # Wait for 1 second before checking again
#     Start-Sleep -Seconds 1
# }

# # Continue with the rest of the script
# Write-Output "Continue with the rest of the script..."

# Check if powershell is in ConstrainedLanguage or FullLanguage mode
$ExecutionContext.SessionState.LanguageMode

# Wait 30 seconds for OneDrive initial processes to settle down
Start-Sleep 30


    
  
    #region Functions
    function Sync-SharepointLocation {
        param (
            [guid]$siteId,
            [guid]$webId,
            [guid]$listId,
            [mailaddress]$userEmail,
            [string]$webUrl,
            [string]$webTitle,
            [string]$listTitle,
            [string]$syncPath
        )
        try {
            Add-Type -AssemblyName System.Web
            #Encode site, web, list, url & email
            [string]$siteId = [System.Web.HttpUtility]::UrlEncode($siteId)
            [string]$webId = [System.Web.HttpUtility]::UrlEncode($webId)
            [string]$listId = [System.Web.HttpUtility]::UrlEncode($listId)
            [string]$userEmail = [System.Web.HttpUtility]::UrlEncode($userEmail)
            [string]$webUrl = [System.Web.HttpUtility]::UrlEncode($webUrl)
            #build the URI
            $uri = New-Object System.UriBuilder
            $uri.Scheme = "odopen"
            $uri.Host = "sync"
            $uri.Query = "siteId=$siteId&webId=$webId&listId=$listId&userEmail=$userEmail&webUrl=$webUrl&listTitle=$listTitle&webTitle=$webTitle"
            #launch the process from URI
            Write-Host $uri.ToString()
            start-process -filepath $($uri.ToString())
        }
        catch {
            $errorMsg = $_.Exception.Message
        }
        if ($errorMsg) {
            Write-Warning "Sync failed."
            Write-Warning $errorMsg
        }
        else {
            Write-Host "Sync completed."
            while (!(Get-ChildItem -Path $syncPath -ErrorAction SilentlyContinue)) {
                Start-Sleep -Seconds 2
            }
            return $true
        }    
    }
    #endregion
    #region Main Process
    
    try {
        #region Sharepoint Sync
        [mailaddress]$userUpn = cmd /c "whoami/upn"
        $params = @{
            #replace with data captured from your sharepoint site.
            siteId    = "{57d8ab06-4fa4-4b1d-8740-08ff0222ff0b}"
            webId     = "{ba60e4ff-c04e-4346-b153-34d1bd1a1eff}"
            listId    = "{598d5507-c0cf-493e-9034-b1f7e2ac9a8c}"
            userEmail = $userUpn
            webUrl    = "https://artsplusorg.sharepoint.com/sites/Shared"
            webTitle  = "Shared"
            listTitle = "Documents"
        }
    
    
        $params.syncPath  = "$(split-path $env:onedrive)\$($userUpn.Host)\$($params.webTitle) - $($Params.listTitle)"
        Write-Host "SharePoint params:"
        $params | Format-Table
        if (!(Test-Path $($params.syncPath))) {
            Write-Host "Sharepoint folder not found locally, will now sync.." -ForegroundColor Yellow
            $sp = Sync-SharepointLocation @params
            if (!($sp)) {
                Throw "Sharepoint sync failed."
            }
        }
        else {
            Write-Host "Location already syncronized: $($params.syncPath)" -ForegroundColor Yellow
        }
        #endregion
    }
    catch {
        $errorMsg = $_.Exception.Message
    }
    finally {
        if ($errorMsg) {
            Write-Warning $errorMsg
            Throw $errorMsg
        }
        else {
            Write-Host "Completed successfully.."
        }
    }
    #endregion

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
    [string]$tenantName = (dsregcmd.exe /status | Select-String -Pattern "TenantName").ToString().Split(":")[1].Trim()
    $params = @{
        #replace with data captured from your sharepoint site.
        siteId    = "{fa562240-8d70-4eee-9052-56cb159b4724}"
        webId     = "{d0edf425-7602-4929-9787-d89b9f996ad9}"
        listId    = "{0613d3e1-d0b2-420a-bd9f-aadad66426b4}"
        userEmail = $userUpn
        webUrl    = "https://renwest.sharepoint.com/sites/Media"
        webTitle  = "Media"
        listTitle = "Documents"
    }
    # Combine some parameters to build a full path for syncronization
    $params.syncPath = "$(split-path $env:onedrive)\$tenantName\$($params.webTitle) - $($Params.listTitle)"
    
    # Display all parameters
    Write-Host "SharePoint params:"
    $params | Format-Table

    # Check if powershell is in ConstrainedLanguage or FullLanguage mode
    Write-Host "Language Mode for Powershell is : [$($ExecutionContext.SessionState.LanguageMode)]"

    #If the 
    if (!(Test-Path $($params.syncPath))) {
        Write-Host "Sharepoint folder not found locally, waiting for OneDrive service to initiate sync..." -ForegroundColor Yellow

        ######################################### Wait for OneDrive ############################################   
        # Wait and Loop until OneDrive process starts
        while ($true) {
            $onedriveProcess = Get-Process "OneDrive" -ErrorAction SilentlyContinue

            if ($onedriveProcess -ne $null) {
                Write-Output "OneDrive is running now."
                Write-Output "Continue!" -ForegroundColor Green
                break
            }
            else {
                Write-Output "OneDrive is not running yet. Waiting..."
            }

            # Wait for 1 second before checking again
            Start-Sleep -Seconds 1
        }

        # Confirm OneDrive has been successfully logged into by the user
        $registryPath = 'HKCU:\SOFTWARE\Microsoft\OneDrive'
        $ValueName = 'ClientEverSignedIn'
        $TargetValue = 1  # Set the target value to 1

        # Loop until the registry value is found
        while ($true) {
            # Use Get-ItemProperty to retrieve the specific registry value
            $registryValue = Get-ItemProperty -Path $registryPath -Name $ValueName | Select-Object -ExpandProperty $ValueName

            # Check if the registry value equals 1
            if ($registryValue -eq $TargetValue) {
                Write-Host "Client is signed into OneDrive: $registryValue"
                break  # Exit the loop when the value is found
            }

            # Display a message and wait before checking again
            Write-Host "Client isn't signed in yet. Waiting..."
            Start-Sleep -Seconds 1  # Adjust the sleep duration as needed
        }

        # Continue with the rest of your script or actions
        Write-Output "Continue with the rest of the script..."

        # Wait 15 seconds for OneDrive initial processes to settle down
        Start-Sleep 15
        #Sleep another interval to keep scripts from colliding.
        Start-Sleep 10
        ################################################## Do the Sync! ###################################
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

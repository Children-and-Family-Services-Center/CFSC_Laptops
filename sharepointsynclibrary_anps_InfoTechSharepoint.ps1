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

# Define the path to the user's OneDrive folder
$OneDrivePath = "$env:userprofile\OneDrive"

# Loop until OneDrive folder exists
while ($true) {
    $onedrivePathExists = Test-Path -Path $OneDrivePath

    if ($onedriveProcess -ne $null) {
        Write-Output "OneDrive synchronization has started for the user."
        break
    } else {
        Write-Output "OneDrive synchronization has not started yet for the user."
    }

    # Wait for 1 second before checking again
    Start-Sleep -Seconds 1
}

# Continue with the rest of the script
Write-Output "Continue with the rest of the script..."

# Wait 1 minute for OneDrive initial processes to settle down
Start-Sleep 60

# "Automating the Syncing of Sharepoint team site libraries" by "Intune Training" channel
# Go to "region sharepoint sync" in this script and replace the variables inside the Params block
#Stolen from https://www.youtube.com/watch?v=Zoac9lbUuG0
    
  
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
        siteId    = "{58830d6a-98ec-4841-bd73-1ed6f51bfa2a}"
        webId     = "{908ed321-8ddc-4aad-bf39-22333a7d740e}"
        listId    = "{a00bc429-5278-40b7-9a1f-4b10375454dc}"
        userEmail = $userUpn
        webUrl    = "https://childrenfamily.sharepoint.com/sites/InformationTechnology"
        webTitle  = "Information Technology"
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
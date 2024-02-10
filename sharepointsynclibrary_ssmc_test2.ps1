Start-Sleep 10
    #Stolen from https://www.youtube.com/watch?v=Zoac9lbUuG0
    # "Automating the Syncing of Sharepoint team site libraries" by "Intune Training" channel
    # Go to "region sharepoint sync" in this script and replace the variables inside the Params block
    
  
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
            siteId    = "{f1329fa9-12e9-4b9d-8ebe-113fc0f8f955}"
            webId     = "{c90aebbf-6122-4cca-af82-ebca42edaa91}"
            listId    = "{b7a2b82b-42ad-4dd9-9cc9-5a785377ece8}"
            userEmail = $userUpn
            webUrl    = "https://meckpre.sharepoint.com/sites/Test2"
            webTitle  = "Test2"
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

<#
.SYNOPSIS
Clears the cache for various web browsers.

.DESCRIPTION
This script clears the cache for Google Chrome, Mozilla Firefox, Microsoft Edge, Internet Explorer, and Opera.

.NOTES
Author: [Your Name]
Date: [Current Date]
#>

function Clear-Cache {
    param (
        [string]$BrowserName,
        [string]$CachePath
    )
    if (Test-Path -Path $CachePath) {
        try {
            Remove-Item -Path $CachePath -Force -Recurse -ErrorAction Stop
            Write-Host "$BrowserName cache cleared successfully."
        } catch {
            Write-Warning "Failed to clear $BrowserName cache: $_"
        }
    } else {
        Write-Host "$BrowserName cache path not found: $CachePath"
    }
}

function Clear-Chrome-Cache {
    $chromeCachePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Google\Chrome\User Data\Default\Cache')
    Clear-Cache -BrowserName 'Google Chrome' -CachePath $chromeCachePath
}

function Clear-Firefox-Cache {
    $firefoxProfilesPath = [System.IO.Path]::Combine($env:APPDATA, 'Mozilla\Firefox\Profiles')
    if (Test-Path -Path $firefoxProfilesPath) {
        $firefoxProfiles = Get-ChildItem -Path $firefoxProfilesPath -Filter '*.default*'
        foreach ($profile in $firefoxProfiles) {
            $cachePath = [System.IO.Path]::Combine($profile.FullName, 'cache2')
            Clear-Cache -BrowserName 'Mozilla Firefox' -CachePath $cachePath
        }
    } else {
        Write-Host "Mozilla Firefox profiles path not found: $firefoxProfilesPath"
    }
}

function Clear-Edge-Cache {
    $edgeCachePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft\Edge\User Data\Default\Cache')
    Clear-Cache -BrowserName 'Microsoft Edge' -CachePath $edgeCachePath
}

function Clear-IE-Cache {
    try {
        Clear-WebBrowserCache -Browser "Internet Explorer"
        Write-Host "Internet Explorer cache cleared successfully."
    } catch {
        Write-Warning "Failed to clear Internet Explorer cache: $_"
    }
}

function Clear-Opera-Cache {
    $operaCachePath = [System.IO.Path]::Combine($env:APPDATA, 'Opera Software\Opera Stable\Cache')
    Clear-Cache -BrowserName 'Opera' -CachePath $operaCachePath
}

function Clear-Browser-Cache {
    Clear-Chrome-Cache
    Clear-Firefox-Cache
    Clear-Edge-Cache
    Clear-IE-Cache
    Clear-Opera-Cache
}

Clear-Browser-Cache

Write-Host "All browser caches cleared successfully."
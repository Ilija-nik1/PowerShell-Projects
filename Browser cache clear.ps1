# Clear cache for Google Chrome
function Clear-Chrome-Cache {
    $chromeCachePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Google\Chrome\User Data\Default\Cache')
    Remove-Item -Path $chromeCachePath -Force -Recurse -ErrorAction SilentlyContinue
}

# Clear cache for Mozilla Firefox
function Clear-Firefox-Cache {
    $firefoxCachePath = [System.IO.Path]::Combine($env:APPDATA, 'Mozilla\Firefox\Profiles')
    $firefoxProfiles = Get-ChildItem -Path $firefoxCachePath -Filter '*.default*'

    foreach ($profile in $firefoxProfiles) {
        $cachePath = [System.IO.Path]::Combine($profile.FullName, 'cache2')
        Remove-Item -Path $cachePath -Force -Recurse -ErrorAction SilentlyContinue
    }
}

# Clear cache for Microsoft Edge
function Clear-Edge-Cache {
    $edgeCachePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft\Edge\User Data\Default\Cache')
    Remove-Item -Path $edgeCachePath -Force -Recurse -ErrorAction SilentlyContinue
}

# Clear cache for Internet Explorer
function Clear-IE-Cache {
    Clear-WebBrowserCache -Browser "Internet Explorer"
}

# Clear cache for Opera
function Clear-Opera-Cache {
    $operaCachePath = [System.IO.Path]::Combine($env:APPDATA, 'Opera Software\Opera Stable\Cache')
    Remove-Item -Path $operaCachePath -Force -Recurse -ErrorAction SilentlyContinue
}

# Main function to clear cache for supported browsers
function Clear-Browser-Cache {
    Clear-Chrome-Cache
    Clear-Firefox-Cache
    Clear-Edge-Cache
    Clear-IE-Cache
    Clear-Opera-Cache
}

# Call the main function to clear cache for supported browsers
Clear-Browser-Cache

Write-Host "Browser cache cleared successfully."
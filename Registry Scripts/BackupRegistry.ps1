param (
    [string]$registryPath = "HKLM:\SOFTWARE\YourRegistryPath",
    [string]$backupFilePath = "C:\Backup\RegistryBackup.reg"
)

# Validate the registry path
if (Test-Path $registryPath -ErrorAction SilentlyContinue) {
    # Backup the registry key
    try {
        Export-Item -LiteralPath $registryPath -Destination $backupFilePath -Force -ErrorAction Stop
        Write-Host "Registry key backed up to $backupFilePath"
    }
    catch {
        Write-Host "Error backing up registry key: $_" -ForegroundColor Red
    }
}
else {
    Write-Host "Error: Registry key not found. Please provide a valid registry path." -ForegroundColor Red
}
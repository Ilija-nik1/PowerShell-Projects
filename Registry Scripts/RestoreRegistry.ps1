param (
    [string]$backupFilePath = "C:\Backup\RegistryBackup.reg"
)

# Validate the backup file
if (Test-Path $backupFilePath -ErrorAction SilentlyContinue) {
    # Restore the registry key
    try {
        Invoke-Expression -Command "reg.exe import `"$backupFilePath`"" -ErrorAction Stop
        Write-Host "Registry key restored from $backupFilePath"
    }
    catch {
        Write-Host "Error restoring registry key: $_" -ForegroundColor Red
    }
}
else {
    Write-Host "Error: Backup file not found. Please provide a valid backup file path." -ForegroundColor Red
}
param (
    [Parameter(Mandatory=$true)]
    [string]$BackupFilePath = "C:\Backup\RegistryBackup.reg"
)

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

# Validate the backup file path
if (-not (Test-Path -Path $BackupFilePath -ErrorAction SilentlyContinue)) {
    Write-Log "Error: Backup file not found at $BackupFilePath. Please provide a valid path." "ERROR"
    exit 1
}

# Restore the registry from the backup file
try {
    Write-Log "Starting registry restoration from $BackupFilePath"
    Invoke-Expression -Command "reg.exe import `"$BackupFilePath`"" -ErrorAction Stop
    Write-Log "Registry key successfully restored from $BackupFilePath"
} catch {
    Write-Log "Error restoring registry key: $_" "ERROR"
    exit 1
}
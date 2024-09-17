param (
    [Parameter(Mandatory=$true)]
    [string]$RegistryPath = "HKLM:\SOFTWARE\YourRegistryPath",

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

# Ensure backup file path directory exists
$backupDir = Split-Path $BackupFilePath -Parent
if (-not (Test-Path -Path $backupDir)) {
    try {
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        Write-Log "Created backup directory at $backupDir"
    } catch {
        Write-Log "Failed to create backup directory: $_" "ERROR"
        exit 1
    }
}

# Validate the registry path
if (Test-Path -Path $RegistryPath -ErrorAction SilentlyContinue) {
    try {
        # Backup the registry key
        Export-Item -LiteralPath $RegistryPath -Destination $BackupFilePath -Force -ErrorAction Stop
        Write-Log "Registry key backed up successfully to $BackupFilePath"
    } catch {
        Write-Log "Error backing up registry key: $_" "ERROR"
        exit 1
    }
} else {
    Write-Log "Registry key not found at path: $RegistryPath" "ERROR"
    exit 1
}
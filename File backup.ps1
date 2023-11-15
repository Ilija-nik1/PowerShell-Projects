# Enhanced PowerShell File Backup Script

function Backup-Files {
    param(
        [string]$sourcePath,
        [string]$destinationPath
    )

    # Validate source and destination paths
    if (-not (Test-Path -Path $sourcePath -PathType Container)) {
        Write-Error "Source path '$sourcePath' not found or is not a valid directory."
        return
    }

    # Create a timestamp for the backup folder
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFolder = Join-Path -Path $destinationPath -ChildPath "Backup_$timestamp"

    # Create the backup folder
    New-Item -ItemType Directory -Path $backupFolder -Force

    # Get all files and subdirectories from the source path
    $itemsToBackup = Get-ChildItem -Path $sourcePath -Recurse

    # Copy each item to the backup folder
    foreach ($item in $itemsToBackup) {
        $destinationItem = Join-Path -Path $backupFolder -ChildPath $item.FullName.Substring($sourcePath.Length)
        Copy-Item -Path $item.FullName -Destination $destinationItem -Force
    }

    Write-Host "Backup completed successfully. Backup folder: $backupFolder"
}

# Example usage
Backup-Files -sourcePath "C:\Path\To\Your\Source" -destinationPath "C:\Path\To\Your\Backup"
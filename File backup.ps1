function Backup-Files {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath
    )

    # Set up logging
    $logFile = "$env:USERPROFILE\Documents\backup_log.txt"

    function Log-Message {
        param (
            [string]$message,
            [string]$level = "INFO",
            [string]$color = "White"
        )
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "$timestamp [$level] - $message" -ForegroundColor $color
        Add-Content -Path $logFile -Value "$timestamp [$level] - $message"
    }

    function Log-Error {
        param (
            [string]$message,
            [Exception]$error
        )
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $detailedError = $error.Exception.Message
        $scriptStackTrace = $error.ScriptStackTrace

        Write-Host "$timestamp [ERROR] - $message" -ForegroundColor Red
        Write-Host "$timestamp [ERROR DETAILS] - $detailedError" -ForegroundColor Red
        Write-Host "$timestamp [STACK TRACE] - $scriptStackTrace" -ForegroundColor Red

        Add-Content -Path $logFile -Value "$timestamp [ERROR] - $message"
        Add-Content -Path $logFile -Value "$timestamp [ERROR DETAILS] - $detailedError"
        Add-Content -Path $logFile -Value "$timestamp [STACK TRACE] - $scriptStackTrace"
    }

    try {
        # Resolve paths to absolute paths
        $resolvedSourcePath = (Resolve-Path -Path $SourcePath).Path
        $resolvedDestinationPath = (Resolve-Path -Path $DestinationPath).Path
    } catch {
        Log-Error "Failed to resolve paths. Error: $_" $_
        return
    }

    # Validate source directory
    if (-not (Test-Path -Path $resolvedSourcePath -PathType Container)) {
        Log-Error "Source path '$resolvedSourcePath' does not exist or is not a directory." $_
        return
    } else {
        Log-Message "Source path '$resolvedSourcePath' validated." "INFO" "Green"
    }

    # Ensure the destination directory exists
    if (-not (Test-Path -Path $resolvedDestinationPath -PathType Container)) {
        try {
            New-Item -ItemType Directory -Path $resolvedDestinationPath -Force | Out-Null
            Log-Message "Destination path '$resolvedDestinationPath' created." "INFO" "Green"
        } catch {
            Log-Error "Failed to create destination path '$resolvedDestinationPath'." $_
            return
        }
    } else {
        Log-Message "Destination path '$resolvedDestinationPath' exists." "INFO" "Green"
    }

    # Create a timestamped backup folder in the destination directory
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFolder = Join-Path -Path $resolvedDestinationPath -ChildPath "Backup_$timestamp"

    try {
        New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
        Log-Message "Backup folder '$backupFolder' created." "INFO" "Green"
    } catch {
        Log-Error "Failed to create backup folder at '$backupFolder'." $_
        return
    }

    # Get all files and directories to backup (relative paths)
    try {
        $itemsToBackup = Get-ChildItem -Path $resolvedSourcePath -Recurse -Force | Where-Object { -not $_.PSIsContainer }
    } catch {
        Log-Error "Error occurred while retrieving items from '$resolvedSourcePath'." $_
        return
    }

    # Initialize a counter for backup summary
    $fileCount = 0

    # Copy each item to the backup folder
    foreach ($item in $itemsToBackup) {
        $relativePath = $item.FullName.Substring($resolvedSourcePath.Length).TrimStart('\')
        $destinationItem = Join-Path -Path $backupFolder -ChildPath $relativePath
        
        # Ensure the target directory exists before copying files
        $targetDir = Split-Path -Path $destinationItem -Parent
        if (-not (Test-Path -Path $targetDir)) {
            try {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                Log-Message "Directory '$targetDir' created." "INFO" "Green"
            } catch {
                Log-Message "Failed to create directory '$targetDir'. Skipping file '$($item.FullName)'..." "WARN" "Yellow"
                continue
            }
        }

        try {
            Copy-Item -Path $item.FullName -Destination $destinationItem -Force
            $fileCount++
            Log-Message "Copied '$($item.FullName)' to '$destinationItem'." "INFO" "Green"
        } catch {
            Log-Message "Failed to copy '$($item.FullName)' to '$destinationItem'." "WARN" "Yellow"
        }
    }

    Log-Message "Backup completed successfully. $fileCount files copied to '$backupFolder'." "SUCCESS" "Green"
}

# Example usage:
Backup-Files -SourcePath "C:\Path\To\Your\Source" -DestinationPath "C:\Path\To\Your\Backup"
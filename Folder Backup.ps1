# Set up source and destination paths
$source = "C:\source"
$destination = "C:\destination"
$logFile = "$env:USERPROFILE\Documents\backup_log.txt" # Log file path

# Set up Robocopy options
$robocopyOptions = @("/MIR", "/FFT", "/Z", "/XA:H", "/XO", "/W:1", "/R:3", "/V", "/NP")

# Function to log messages to console and file
function Log-Message {
    param (
        [string]$message,
        [string]$level = "INFO",
        [string]$color = "White"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $formattedMessage = "$timestamp [$level] - $message"
    Write-Host $formattedMessage -ForegroundColor $color
    Add-Content -Path $logFile -Value $formattedMessage
}

# Function to log detailed error information
function Log-Error {
    param (
        [string]$message,
        [Exception]$error
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $detailedError = $error.Exception.Message
    $scriptStackTrace = $error.ScriptStackTrace

    $errorMessages = @(
        "$timestamp [ERROR] - $message",
        "$timestamp [ERROR DETAILS] - $detailedError"
    )

    if ($scriptStackTrace) {
        $errorMessages += "$timestamp [STACK TRACE] - $scriptStackTrace"
    } else {
        $errorMessages += "$timestamp [STACK TRACE] - No stack trace available."
    }
    
    foreach ($msg in $errorMessages) {
        Write-Host $msg -ForegroundColor Red
        Add-Content -Path $logFile -Value $msg
    }
}

# Ensure source directory exists
try {
    if (-not (Test-Path -Path $source)) {
        throw [System.IO.DirectoryNotFoundException]::new("Source folder '$source' not found.")
    }
    Log-Message "Source folder '$source' exists. Proceeding with backup." "INFO" "Green"
} catch {
    Log-Error "Source folder not found. Backup process aborted." $_
    exit 1
}

# Ensure destination directory exists
try {
    if (-not (Test-Path -Path $destination)) {
        Log-Message "Destination folder '$destination' not found. Creating the directory..." "WARN" "Yellow"
        New-Item -ItemType Directory -Path $destination -Force
        Log-Message "Successfully created destination folder '$destination'." "INFO" "Green"
    } else {
        Log-Message "Destination folder '$destination' exists." "INFO" "Green"
    }
} catch {
    Log-Error "Failed to create destination folder '$destination'." $_
    exit 1
}

# Start backup
Log-Message "Starting backup from '$source' to '$destination'..." "INFO" "Cyan"
try {
    $robocopyResult = robocopy $source $destination $robocopyOptions 2>&1
} catch {
    Log-Error "Failed to execute Robocopy command." $_
    exit 1
}

# Capture and check Robocopy exit code
$exitCode = $LASTEXITCODE

switch ($exitCode) {
    0 { Log-Message "Backup completed successfully with no changes." "SUCCESS" "Green" }
    1 { Log-Message "Backup completed successfully with some changes." "SUCCESS" "Green" }
    2 { Log-Message "Backup completed successfully with extra files copied." "SUCCESS" "Green" }
    3 { Log-Message "Backup completed with some errors. Check the log for details." "WARN" "Yellow" }
    default { 
        Log-Message "Backup failed with errors. Exit code: $exitCode." "ERROR" "Red"
        exit 1
    }
}

# Log exit code to file
Log-Message "Robocopy finished with exit code $exitCode." "INFO"

# Check Robocopy output for errors
if ($robocopyResult -match "ERROR") {
    Log-Message "Robocopy encountered errors during the backup process. Review the detailed log output for more information." "ERROR" "Red"
}

Log-Message "Backup process completed." "INFO" "Green"
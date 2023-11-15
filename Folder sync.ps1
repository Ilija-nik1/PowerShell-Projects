# Enhanced PowerShell Folder Synchronization Script

function Test-PathOrError {
    param (
        [string]$path,
        [string]$type
    )

    if (-not (Test-Path -Path $path -PathType $type)) {
        Write-Error "$type path '$path' not found or is not a valid $type."
        return $false
    }

    return $true
}

function Sync-Folders {
    param (
        [string]$sourcePath,
        [string]$destinationPath
    )

    # Validate source and destination paths
    if (-not (Test-PathOrError -path $sourcePath -type Container)) { return }
    if (-not (Test-PathOrError -path $destinationPath -type Container)) { return }

    # Use Robocopy for synchronization
    $robocopyArgs = "/mir /fft /np /ndl /nfl /xd .git"  # Customize these arguments as needed
    $robocopyCommand = "robocopy `"$sourcePath`" `"$destinationPath`" $robocopyArgs"

    # Execute the Robocopy command
    Invoke-Expression -Command $robocopyCommand

    Write-Host "Synchronization completed successfully."
}

# Example usage
Sync-Folders -sourcePath "C:\Path\To\Your\Source" -destinationPath "C:\Path\To\Your\Destination"
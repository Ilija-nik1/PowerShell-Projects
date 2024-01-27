function Test-PathOrError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Container', 'Leaf')]
        [string]$Type
    )

    if (-not (Test-Path -Path $Path -PathType $Type)) {
        throw "$Type path '$Path' not found or is not a valid $Type."
    }

    return $true
}

function Sync-Folders {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath,

        [string]$RobocopyArgs = "/mir /fft /np /ndl /nfl /xd .git"
    )

    # Validate source and destination paths
    Test-PathOrError -Path $SourcePath -Type Container
    Test-PathOrError -Path $DestinationPath -Type Container

    # Prepare arguments for Robocopy
    $arguments = @($SourcePath, $DestinationPath, $RobocopyArgs -split ' ')

    # Execute the Robocopy command
    Start-Process robocopy -ArgumentList $arguments -NoNewWindow -Wait

    Write-Host "Synchronization completed successfully."
}

# Example usage
Sync-Folders -SourcePath "C:\Path\To\Your\Source" -DestinationPath "C:\Path\To\Your\Destination"
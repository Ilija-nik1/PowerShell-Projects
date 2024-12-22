<#
.SYNOPSIS
    Reset Network Settings Script.

.DESCRIPTION
    This script resets network settings by flushing DNS, clearing the ARP cache, 
    and releasing and renewing the IP configuration. It includes logging 
    capabilities and ensures it is run with administrator privileges.

.NOTES
    Author: Your Name
    Date: 2024-06-30
#>

# Define a reusable function to run commands and handle output
function Invoke-CommandWithLogging {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [string]$SuccessMessage,

        [Parameter(Mandatory = $true)]
        [string]$ErrorMessage,

        [Parameter(Mandatory = $false)]
        [string]$LogFile = ""
    )

    try {
        Write-Verbose "Executing command: $Command"
        Invoke-Expression -Command $Command

        Write-Host $SuccessMessage -ForegroundColor Green
        if ($LogFile) {
            Add-Content -Path $LogFile -Value "$(Get-Date) - SUCCESS: $SuccessMessage"
        }
    } catch {
        Write-Host $ErrorMessage -ForegroundColor Red
        Write-Host "Error Details: $_" -ForegroundColor Red

        if ($LogFile) {
            Add-Content -Path $LogFile -Value "$(Get-Date) - ERROR: $ErrorMessage - Details: $_"
        }
    }
}

# Function to flush the DNS cache
function Flush-Dns {
    [CmdletBinding()]
    param (
        [string]$LogFile = ""
    )
    Invoke-CommandWithLogging -Command "ipconfig /flushdns" `
                              -SuccessMessage "DNS cache flushed successfully." `
                              -ErrorMessage "Failed to flush DNS cache." `
                              -LogFile $LogFile
}

# Function to clear the ARP cache
function Clear-ArpCache {
    [CmdletBinding()]
    param (
        [string]$LogFile = ""
    )
    Invoke-CommandWithLogging -Command "arp -d *" `
                              -SuccessMessage "ARP cache cleared successfully." `
                              -ErrorMessage "Failed to clear ARP cache." `
                              -LogFile $LogFile
}

# Function to release and renew the IP configuration
function Release-Renew-IpConfig {
    [CmdletBinding()]
    param (
        [string]$LogFile = ""
    )
    Invoke-CommandWithLogging -Command "ipconfig /release" `
                              -SuccessMessage "IP configuration released successfully." `
                              -ErrorMessage "Failed to release IP configuration." `
                              -LogFile $LogFile

    Invoke-CommandWithLogging -Command "ipconfig /renew" `
                              -SuccessMessage "IP configuration renewed successfully." `
                              -ErrorMessage "Failed to renew IP configuration." `
                              -LogFile $LogFile
}

# Main function to reset network settings
function Reset-NetworkSettings {
    [CmdletBinding()]
    param (
        [switch]$FlushOnly,
        [switch]$ClearArpOnly,
        [switch]$RenewIpOnly,
        [string]$LogFile = ""
    )

    Begin {
        Write-Host "Starting network settings reset..." -ForegroundColor Yellow
        if ($LogFile) {
            Add-Content -Path $LogFile -Value "$(Get-Date) - INFO: Starting network settings reset..."
        }
    }

    Process {
        if ($FlushOnly) {
            Flush-Dns -LogFile $LogFile
        } elseif ($ClearArpOnly) {
            Clear-ArpCache -LogFile $LogFile
        } elseif ($RenewIpOnly) {
            Release-Renew-IpConfig -LogFile $LogFile
        } else {
            Flush-Dns -LogFile $LogFile
            Clear-ArpCache -LogFile $LogFile
            Release-Renew-IpConfig -LogFile $LogFile
        }
    }

    End {
        Write-Host "Network settings reset completed." -ForegroundColor Yellow
        if ($LogFile) {
            Add-Content -Path $LogFile -Value "$(Get-Date) - INFO: Network settings reset completed."
        }
    }
}

# Function to ensure the script runs with administrator privileges
function Ensure-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This script requires administrator privileges. Restarting with elevated permissions..." -ForegroundColor Red
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
        exit
    }
}

# Entry point
Ensure-Admin
Reset-NetworkSettings @PSBoundParameters
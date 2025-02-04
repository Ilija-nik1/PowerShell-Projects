<#
.SYNOPSIS
    Resets network settings by releasing/renewing IP addresses, flushing DNS,
    resetting the TCP/IP stack and Winsock, and clearing the ARP cache.

.DESCRIPTION
    This script must be run as Administrator. It performs the following actions:
      • Releases the current IP configuration.
      • Flushes the DNS cache.
      • Renews the IP configuration.
      • Resets the TCP/IP stack.
      • Resets the Winsock catalog.
      • Clears the ARP cache.
    Finally, it notifies the user of success and offers an option to reboot.

.EXAMPLE
    .\Reset-Network.ps1
#>

function Test-Administrator {
    <#
    .SYNOPSIS
        Verifies that the script is running with administrative privileges.
    #>
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run as Administrator. Please re-run it with elevated privileges."
    }
}

function Execute-ExternalCommand {
    <#
    .SYNOPSIS
        Executes an external command using cmd.exe and verifies it completes successfully.
    .PARAMETER Command
        The command to execute.
    .PARAMETER SuccessMessage
        Optional message to display on success.
    .PARAMETER DelaySeconds
        Number of seconds to pause after the command completes.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $false)]
        [string]$SuccessMessage = "",
        [Parameter(Mandatory = $false)]
        [int]$DelaySeconds = 2
    )
    
    Write-Host "Executing: $Command" -ForegroundColor Yellow
    # Use Start-Process to run the command via cmd.exe
    $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $Command" -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "Command '$Command' failed with exit code $($process.ExitCode)."
    }
    if ($SuccessMessage) {
        Write-Host $SuccessMessage -ForegroundColor Green
    }
    Start-Sleep -Seconds $DelaySeconds
}

try {
    # Ensure the script is running as Administrator.
    Test-Administrator

    Write-Host "Starting network reset..." -ForegroundColor Cyan

    # Release current IP configuration.
    Execute-ExternalCommand -Command "ipconfig /release" -SuccessMessage "IP address released."

    # Flush the DNS cache.
    Execute-ExternalCommand -Command "ipconfig /flushdns" -SuccessMessage "DNS cache flushed."

    # Renew IP configuration.
    Execute-ExternalCommand -Command "ipconfig /renew" -SuccessMessage "IP address renewed."

    # Reset TCP/IP stack.
    Execute-ExternalCommand -Command "netsh int ip reset" -SuccessMessage "TCP/IP stack reset."

    # Reset Winsock settings.
    Execute-ExternalCommand -Command "netsh winsock reset" -SuccessMessage "Winsock reset."

    # Clear ARP cache.
    Execute-ExternalCommand -Command "netsh interface ip delete arpcache" -SuccessMessage "ARP cache cleared."

    Write-Host "Network settings have been reset successfully." -ForegroundColor Green
    Write-Host "It is recommended that you reboot your system to ensure all changes take effect." -ForegroundColor Cyan

    # Optionally prompt the user to reboot.
    $reboot = Read-Host "Would you like to reboot now? (Y/N)"
    if ($reboot -match '^[Yy]') {
        Write-Host "Rebooting system..." -ForegroundColor Cyan
        Restart-Computer -Force
    }
    else {
        Write-Host "Please remember to reboot your system later." -ForegroundColor Yellow
    }
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}
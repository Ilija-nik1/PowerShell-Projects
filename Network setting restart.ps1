# Reset Network Settings Script

function Run-Command {
    param(
        [string]$command,
        [string]$successMessage
    )

    try {
        Write-Host $command
        Invoke-Expression -Command $command
        Write-Host $successMessage
    } catch {
        Write-Host "Error: $_"
    }
}

function Flush-Dns {
    Run-Command -command "ipconfig /flushdns" -successMessage "DNS Flushed successfully."
}

function Clear-ArpCache {
    Run-Command -command "arp -d" -successMessage "ARP cache cleared successfully."
}

function Release-Renew-IpConfig {
    Run-Command -command "ipconfig /release" -successMessage "IP configuration released successfully."
    Run-Command -command "ipconfig /renew" -successMessage "IP configuration renewed successfully."
}

function Reset-NetworkSettings {
    Flush-Dns
    Clear-ArpCache
    Release-Renew-IpConfig
    Write-Host "Network settings reset completed."
}

# Call the main function
Reset-NetworkSettings
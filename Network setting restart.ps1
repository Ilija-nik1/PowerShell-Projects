# Reset Network Settings Script

function Flush-Dns {
    try {
        Write-Host "Flushing DNS..."
        ipconfig /flushdns
        Write-Host "DNS Flushed successfully."
    } catch {
        Write-Host "Error flushing DNS: $_"
    }
}

function Clear-ArpCache {
    try {
        Write-Host "Clearing ARP cache..."
        arp -d
        Write-Host "ARP cache cleared successfully."
    } catch {
        Write-Host "Error clearing ARP cache: $_"
    }
}

function Release-Renew-IpConfig {
    try {
        Write-Host "Releasing and renewing IP configuration..."
        ipconfig /release
        ipconfig /renew
        Write-Host "IP configuration released and renewed successfully."
    } catch {
        Write-Host "Error releasing and renewing IP configuration: $_"
    }
}

function Reset-NetworkSettings {
    Flush-Dns
    Clear-ArpCache
    Release-Renew-IpConfig
    Write-Host "Network settings reset completed."
}

# Call the main function
Reset-NetworkSettings
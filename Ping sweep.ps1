# Enhanced PowerShell Ping Sweep Script

function Test-IPRange {
    param (
        [string]$startIP,
        [string]$endIP,
        [int]$timeoutMilliseconds = 500  # Default timeout is 500 milliseconds
    )

    $ipRange = 1..254  # Customize the range as needed

    foreach ($suffix in $ipRange) {
        $currentIP = "$startIP.$suffix"
        $result = Test-Connection -ComputerName $currentIP -Count 1 -ErrorAction SilentlyContinue -TimeoutMillis $timeoutMilliseconds

        if ($result -ne $null -and $result.StatusCode -eq 0) {
            $hostInfo = @{
                "IPAddress" = $currentIP
                "ResponseTime" = $result.ResponseTime
                "TTL" = $result.TimeToLive
                "BufferSize" = $result.BufferSize
                "Fragmentation" = $result.Fragmentation
                "BytesTransmitted" = $result.BytesTransmitted
                "BytesReceived" = $result.BytesReceived
            }
            
            $hostInfoString = $hostInfo | Format-Table | Out-String
            Write-Host "Host $currentIP is online. Details:`n$hostInfoString"
        } elseif ($result -ne $null -and $result.StatusCode -eq 11010) {
            Write-Host "Host $currentIP is online but ICMP echo request is not allowed."
        } else {
            Write-Host "Host $currentIP is offline."
        }
    }
}

# Example usage
Test-IPRange -startIP "192.168.1" -endIP "192.168.1" -timeoutMilliseconds 1000
# Define the network prefix
$networkPrefix = "192.168.1."

# Create an empty array to store jobs
$jobs = @()

# Loop through IP addresses from 192.168.1.1 to 192.168.1.254
1..254 | ForEach-Object {
    $ip = "$networkPrefix$_"

    # Start a background job to ping each IP address
    $jobs += Start-Job -ScriptBlock {
        param($ip)
        try {
            $pingResult = Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutSeconds 1
            if ($pingResult) {
                [PSCustomObject]@{ IP = $ip; Status = "Up" }
            } else {
                [PSCustomObject]@{ IP = $ip; Status = "Down" }
            }
        } catch {
            [PSCustomObject]@{ IP = $ip; Status = "Error" }
        }
    } -ArgumentList $ip
}

# Wait for all jobs to finish
$jobs | ForEach-Object { $_ | Wait-Job }

# Collect results from all jobs
$results = $jobs | ForEach-Object { Receive-Job -Job $_ } | Sort-Object IP

# Display results in a table
$results | Format-Table -AutoSize

# Clean up all jobs
$jobs | ForEach-Object { $_ | Remove-Job }
[CmdletBinding()]
param()

# Verify that the Hyper-V module is available
if (-not (Get-Module -ListAvailable -Name Hyper-V)) {
    Write-Error "The Hyper-V module is not available on this system. Please enable/install the Hyper-V feature."
    exit
}

Import-Module Hyper-V

# Function to retrieve VHD usage details
function Get-VHDUsage {
    $vhdSummary = @()
    $totalVHDSize = 0
    $vms = Get-VM

    Write-Host "Scanning Hyper-V VMs and their VHD files..." -ForegroundColor Cyan
    foreach ($vm in $vms) {
        Write-Host "Processing VM: $($vm.Name)" -ForegroundColor Yellow
        $vhdDrives = Get-VMHardDiskDrive -VMName $vm.Name

        foreach ($drive in $vhdDrives) {
            try {
                if (Test-Path $drive.Path) {
                    $fileInfo = Get-Item $drive.Path
                    $size = $fileInfo.Length
                    $totalVHDSize += $size
                    $vhdSummary += [pscustomobject]@{
                        VMName  = $vm.Name
                        VHDPath = $drive.Path
                        SizeGB  = [math]::Round($size / 1GB, 2)
                    }
                } else {
                    Write-Warning "File not found: $($drive.Path) for VM: $($vm.Name)"
                }
            } catch {
                Write-Warning "Error processing file $($drive.Path): $_"
            }
        }
    }
    return @{ TotalVHDSize = $totalVHDSize; VHDDetails = $vhdSummary }
}

# Function to retrieve disk usage details for all file system drives
function Get-DiskUsage {
    $diskSummary = @()
    $drives = Get-PSDrive -PSProvider FileSystem
    $totalDiskSize = 0
    $totalFreeSpace = 0

    Write-Host "Scanning local disk drives..." -ForegroundColor Cyan
    foreach ($drive in $drives) {
        try {
            # Calculate drive size (Used + Free)
            $driveSize = $drive.Used + $drive.Free
            $usedSpace = $drive.Used
            $freeSpace = $drive.Free
            $totalDiskSize += $driveSize
            $totalFreeSpace += $freeSpace
            $diskSummary += [pscustomobject]@{
                Drive       = $drive.Name
                TotalSizeGB = [math]::Round($driveSize / 1GB, 2)
                UsedSpaceGB = [math]::Round($usedSpace / 1GB, 2)
                FreeSpaceGB = [math]::Round($freeSpace / 1GB, 2)
            }
        } catch {
            Write-Warning "Error processing drive $($drive.Name): $_"
        }
    }
    return @{ TotalDiskSize = $totalDiskSize; TotalFreeSpace = $totalFreeSpace; DiskDetails = $diskSummary }
}

# Retrieve Hyper-V VHD usage
$vhdResult = Get-VHDUsage
$totalVHDSize = $vhdResult.TotalVHDSize
$totalVHDSizeGB = [math]::Round($totalVHDSize / 1GB, 2)

# Retrieve overall disk usage
$diskResult = Get-DiskUsage
$totalDiskSize = $diskResult.TotalDiskSize
$totalFreeSpace = $diskResult.TotalFreeSpace
$totalDiskSizeGB = [math]::Round($totalDiskSize / 1GB, 2)
$totalFreeSpaceGB = [math]::Round($totalFreeSpace / 1GB, 2)

# Calculate percentage of total disk space used by Hyper-V VHD files
$percentageUsedByVHDs = if ($totalDiskSize -gt 0) { [math]::Round(($totalVHDSize / $totalDiskSize) * 100, 2) } else { 0 }

# Output summary to console
Write-Host "========================================" -ForegroundColor Green
Write-Host "Hyper-V VHD Usage Summary:" -ForegroundColor Green
Write-Host "Total space used by Hyper-V VHD files: $totalVHDSizeGB GB"
Write-Host "Percentage of total disk space used by VHD files: $percentageUsedByVHDs %"
Write-Host "`nDetailed Disk Drives Information:" -ForegroundColor Green
$diskResult.DiskDetails | Format-Table -AutoSize

Write-Host "`nOverall Disk Summary:" -ForegroundColor Green
Write-Host "Total disk size across all drives: $totalDiskSizeGB GB"
Write-Host "Total free disk space available:   $totalFreeSpaceGB GB"
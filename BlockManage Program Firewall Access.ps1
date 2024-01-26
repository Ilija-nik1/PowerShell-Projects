# Enhanced and Optimized PowerShell Script for Managing Internet Access of a Specific Program

function Manage-ProgramInternetAccess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProgramPath,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Block", "Unblock")]
        [string]$Action
    )

    # Validate program path
    if (-not (Test-Path -Path $ProgramPath -PathType Leaf)) {
        Write-Warning "The specified program path does not exist: $ProgramPath"
        return
    }

    $programName = (Get-Item -Path $ProgramPath).Name
    $ruleNameOutbound = "BlockOutboundInternetAccessFor_$programName"
    $ruleNameInbound = "BlockInboundInternetAccessFor_$programName"

    # Function to create or remove firewall rules
    function Set-FirewallRule {
        param (
            [string]$RuleName,
            [string]$Direction,
            [string]$Action
        )

        $ruleExists = (Get-NetFirewallRule -Name $RuleName -ErrorAction SilentlyContinue) -ne $null

        if ($Action -eq 'Block') {
            if (-not $ruleExists) {
                New-NetFirewallRule -DisplayName $RuleName -Direction $Direction -Program $ProgramPath -Action Block -Protocol TCP
                New-NetFirewallRule -DisplayName $RuleName -Direction $Direction -Program $ProgramPath -Action Block -Protocol UDP
                Write-Host "Blocked $Direction internet access (TCP and UDP) for $programName" -ForegroundColor Green
            } else {
                Write-Host "Firewall rule ($RuleName) for $Direction already exists." -ForegroundColor Yellow
            }
        } elseif ($Action -eq 'Unblock') {
            if ($ruleExists) {
                Get-NetFirewallRule -Name $RuleName | Remove-NetFirewallRule
                Write-Host "Unblocked $Direction internet access for $programName" -ForegroundColor Green
            } else {
                Write-Host "Firewall rule ($RuleName) for $Direction does not exist." -ForegroundColor Yellow
            }
        }
    }

    # Apply firewall rules
    Set-FirewallRule -RuleName $ruleNameOutbound -Direction "Outbound" -Action $Action
    Set-FirewallRule -RuleName $ruleNameInbound -Direction "Inbound" -Action $Action
}

# User Interaction
$programPath = Read-Host "Enter the full path to the executable of the program"
$action = Read-Host "Do you want to 'Block' or 'Unblock' internet access for this program? (Block/Unblock)"

Manage-ProgramInternetAccess -ProgramPath $programPath -Action $action
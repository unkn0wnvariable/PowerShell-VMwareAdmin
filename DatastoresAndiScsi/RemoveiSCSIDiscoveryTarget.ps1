# Script to remove an iSCSI target from all ESXi hosts in a vCenter
#
# Updated for PowerCLI 10
#

# What are the addresses of the targets are we removing? (Can be 1 or more)
$addressesToRemove = @('','')

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

# Get all hosts attached to vSphere server
$vmHosts = Get-VMHost -Server $viServer | Sort-Object -Property Name

# Iterate through the hosts removing the iSCSI target where it is present
foreach ($vmHost in $vmHosts) {
    foreach ($addressToRemove in $addressesToRemove) {
        Write-Host -Object ('Removing iSCSI target ' + $addressToRemove + ' from ' + $vmHost + '... ') -NoNewline
        $vmHostHba = $vmHost | Get-VMHostHba -Type IScsi
        $targetToRemove = Get-IScsiHbaTarget -IScsiHba $vmHostHba | Where-Object {$_.Address -eq $addressToRemove}
        if ($targetToRemove) {
            try {
                Remove-IScsiHbaTarget -Target $targetToRemove -Confirm:$false -ErrorAction:Stop
                Write-Host -Object 'Removed OK.' -ForegroundColor Green
            }
            catch {
                Write-Host -Object 'Failed.' -ForegroundColor Red
            }
        }
        else {
            Write-Host -Object 'Not configured.' -ForegroundColor Red
        }
    }
}

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

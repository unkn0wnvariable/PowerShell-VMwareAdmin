﻿# Output a CSV file containing some details about powered off VMs
#
# Written for PowerCLI 10
#

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force -DisableNameChecking
Connect-VIServer -Server $viServer -Credential $viCredential

# Path to create output file
$outputFile = 'C:\Temp\PoweredOffVMs.csv'

# Get list of all powered off VMs
$vmList = Get-VM -Server $viServer | Where-Object {$_.PowerState -eq 'PoweredOff'}

# Create blank hashtable for results
$outputTable = @()

# Run through the VM's getting the information we need
foreach ($vm in $vmList) {
    $datastoreName = (Get-View $vm.DatastoreIdList).Name
    $vmProvisionedSpace = [math]::Round($vm.ProvisionedSpaceGB,2)
    $outputRow = [pscustomobject]@{
        'VM Name' = $vm.Name;
        'Size (GB)' = $vmProvisionedSpace;
        'Folder' = $vm.Folder;
        'Datastore' = $datastoreName;
        'Resource Pool' = $vm.ResourcePool;
        'Notes' = $vm.Notes
    }
    $outputTable += $outputRow
}

# Output the collected info to a file
$outputTable | Export-Csv -Path $outputFile -NoTypeInformation

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

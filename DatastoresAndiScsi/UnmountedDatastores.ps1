﻿# Script to get a count and list of datastores which are in unmounted
#
# Updated for PowerCLI 10
#

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

# Get Unmounted Datastores
$unmountedStores = Get-Datastore -Server $viServer | Where-Object {$_.State -eq 'Unavailable'} | Select-Object Name,@{N='CanonicalName';E={$_.ExtensionData.Info.Vmfs.Extent[0].DiskName}},CapacityGB,FreeSpaceGB,State

# How many were there?
Write-Host ('There are ' + $unmountedStores.Name.Count + ' unmounted datastores.')

# Display table of results
$unmountedStores | Export-Csv -Path 'C:\Temp\UmountedDatastores.csv' -NoTypeInformation

# Output the naa numbers to a file for later use
$unmountedStores.CanonicalName | Out-File -FilePath 'C:\Temp\UmountedDatastoreNaas.txt'

# Output the names to a file for later use
$unmountedStores.Name | Out-File -FilePath 'C:\Temp\UmountedDatastoreNames.txt'

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

# Script to get a list of all currently unused LUNs attached to vCenter
#
# Updated for PowerCLI 10
#

# Where to save the results to?
$outputFile = 'C:\Temp\UnusedLUNs.txt'

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

# Initialise the $unusedLUNs variable
$unusedLUNs = @()

# Iterate through the ESX hosts attached to vCenter getting unused LUNs from each
foreach ($esxHost in (Get-VMHost -Server $viServer)) { 
    $datastoreSystem = Get-View $vmHost.Extensiondata.ConfigManager.DatastoreSystem
    $unusedLUNs += ($datastoreSystem.QueryAvailableDisksForVmfs($null) | Select-Object CanonicalName).CanonicalName
}

# Remove duplicates from the list
$unusedLUNs = $unusedLUNs | Sort-Object -Unique

# Out put list to file
$unusedLUNs | Out-File -filepath $outputFile

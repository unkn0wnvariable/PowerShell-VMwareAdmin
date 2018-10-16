# Script to get a check time, date and NTP settings from VMhosts
#
# Created for PowerCLI 10
#

# Get Credentials
$viCredential = Get-Credential -Message 'Enter credentials for VMware connection'

# Get vSphere server name
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'

# Import the PowerCLI Module and Connect
Import-Module -Name VMware.PowerCLI -Force
Connect-VIServer -Server $viServer -Credential $viCredential

# Get all connected and powered on hosts attached to vSphere server
$vmHosts = Get-VMHost -Server $viServer | Where-Object {$_.ConnectionState -eq 'Connected' -and $_.PowerState -eq 'PoweredOn'}

# Initialize an object to collect the details into
$hostDetails = @()

# Iterate through the hosts retriving the time and date, ntp service status and ntp server settings
# then put it all together into a table of ordered dictionary objects.
foreach ($vmHost in $vmHosts) {
    $currentTime = Get-Date
    $vmHostTime = (Get-View -Id $vmHost.ExtensionData.ConfigManager.DateTimeSystem).QueryDateTime().ToLocalTime()
    $ntpRunning = (Get-VMHostService -VMHost $vmHost.Name | Where-Object {$_.Key -eq 'ntpd'}).Running
    $ntpServers = Get-VMHostNtpServer -VMHost $vmHost.Name

    $objProperties = [ordered]@{
        'VMHost'=$vmHost.Name;
        'CurrentTime'=$currentTime;
        'HostTime'=$vmHostTime;
        'NTPRunning'=$ntpRunning;
        'NTPServers'=$ntpServers
    }

    $hostDetails += New-Object –TypeName PSObject –Prop $objProperties
}

# Output to an on screen table. You could also export to CSV here.
$hostDetails | Format-Table -AutoSize

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

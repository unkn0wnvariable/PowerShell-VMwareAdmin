﻿# Check syslog is configured for the correct location and 
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

# New Log Datastore
$logDatastore = ''

# What should the log path be?
$logDatastoreUuid = (Get-Datastore -Name $logDatastore -Server $viServer).ExtensionData.Info.Vmfs.Uuid
Write-Host -Object ('New log path should be: /vmfs/volumes/' + $logDatastoreUuid + '/logdir')

# Get all ESX hosts
$esxHosts = Get-VMHost -Server $viServer

# Iterate through the hosts checking log settings
foreach ($esxHost in $esxHosts) { 
    $esxCli = Get-EsxCli -VMHost $esxHost -Server $viServer -V2
    $logSettings = $esxCli.system.syslog.config.get.Invoke()
    Write-Host -Object ('ESXi Host: ' + $esxHost.Name)
    Write-Host -Object ('Log Path: ' + $logSettings.LocalLogOutput)
    Write-Host -Object ('Create subdirectory: ' + $logSettings.LogToUniqueSubdirectory)
}

# Do you want to reload?
$reloadOK = ''
While ($reloadOK -notmatch '^[NnYy]$') {
    $reloadOK = Read-Host -Prompt 'Do you want to reload vmsyslogd? (Y/N)'
}

# If required iterate through the hosts reloading syslog
if ($reloadOK -match '[Yy]') {
    foreach ($esxHost in $esxHosts) { 
        $esxCli = Get-EsxCli -VMHost $esxHost -Server $viServer -V2
        $esxCli.system.syslog.reload.Invoke()
    }
}

# Disconnect from the vSphere server
Disconnect-VIServer -Server $viServer -Confirm:$false

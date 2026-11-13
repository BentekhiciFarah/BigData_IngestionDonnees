. "$PSScriptRoot\common.ps1"
Test-Prerequisites
Test-Environment
Invoke-Native docker @('compose', '--profile', 'bi', 'ps')
Invoke-Native $script:Abctl @('local', 'status')
foreach ($hostName in @('dsid-espocrm-db', 'dsid-postgres')) {
    Invoke-Native docker @('exec', 'airbyte-abctl-control-plane', 'getent', 'hosts', $hostName)
}
Invoke-Native docker @('exec', 'airbyte-abctl-control-plane', 'kubectl', 'get', 'pods', '-n', 'airbyte-abctl')
Invoke-Native docker @('exec', 'airbyte-abctl-control-plane', 'kubectl', 'events', '--types', 'Warning', '-n', 'airbyte-abctl')
Write-Host 'Les tests Airbyte source, destination et synchronisation restent necessaires.'

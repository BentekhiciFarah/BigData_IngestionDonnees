. "$PSScriptRoot\common.ps1"
Test-Prerequisites
Test-Environment
Test-Owner
Invoke-Native docker @('compose', '--profile', 'bi', 'stop')
if (Test-Container 'airbyte-abctl-control-plane') { Invoke-Native docker @('stop', 'airbyte-abctl-control-plane') }
Write-Host 'Arrete. Les volumes et donnees sont conserves.'

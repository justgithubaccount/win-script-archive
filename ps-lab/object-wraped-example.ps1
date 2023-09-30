Clear-Host

$a = Get-NetFirewallRule -DisplayGroup 'mDNS' | Get-NetFirewallPortFilter
$b = (Get-NetFirewallRule -DisplayGroup 'mDNS' | Get-NetFirewallPortFilter).Protocol

$a.Protocol
Write-Host '---'
$b
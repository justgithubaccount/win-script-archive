#========================
# User Defined Settings
#========================
$DomainName = "MyDomain.FQDN"
$TargetGPO = "SYST-DomainControllers_Firewall"
$RuleSetArray = @("Active Directory Domain Services","DNS Service","DFS Replication","DFS Management","Kerberos Key Distribution Center","Core Networking","DHCP Server","DHCP Server Management","Remote Desktop")
$PolicyStore = $DomainName+"\"+$TargetGPO
    
#========================
# Create GPO
#========================
Write-Host "Creating GPO: $TargetGPO"
$Result = New-GPO $TargetGPO
    
#========================
# Add Firewall Rules
#========================
Foreach ($RuleSet in $RuleSetArray) {
    $Rules = Get-NetFirewallRule -displaygroup $RuleSet
    $Rules | ForEach {
    	Write-Host "Adding rule: $($_.DisplayName)"
    	$Result = New-NetFirewallRule -displayname $_.Displayname -PolicyStore $PolicyStore
    }
}
    
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Allow -AllowLocalFirewallRules False -PolicyStore $PolicyStore
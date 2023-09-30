Clear-Host

# Invoke-Command -FilePath "\\domain.ru\vault\scr" -ComputerName CompName

function Get-FirewallGroupRules ($fwGroup) {
    Get-NetFirewallRule -DisplayGroup $fwGroup |
    Format-Table -Property Name,
    DisplayName,
    # DisplayGroup,
    @{Name = 'Protocol'; Expression = { ($_ | Get-NetFirewallPortFilter).Protocol } },
    @{Name = 'LocalPort'; Expression = { ($_ | Get-NetFirewallPortFilter).LocalPort } },
    @{Name = 'RemotePort'; Expression = { ($_ | Get-NetFirewallPortFilter).RemotePort } },
    @{Name = 'RemoteAddress'; Expression = { ($_ | Get-NetFirewallAddressFilter).RemoteAddress } },
    # Enabled,
    Profile,
    Direction,
    Action
}

# $domainName = (Get-ADDomain).DNSRoot
# $listDC = Get-ADDomainController -Filter * -Server $domainName | Select-Object Hostname

$listDC = @('dc-tver.domain.ru', 'bdc-tver.domain.ru')

foreach ($dc in $listDC) {

    Write-Host "Установка связи c $dc"

    $dcSync = New-PSSession -ComputerName $dc

    Enter-PSSession -Session $dcSync

    $allRules = @()
    $allInboundRules = @()
    $allOutboundRules = @()
    $fwGroupNames = @()
    
    $allRules = Get-NetFirewallRule | Where-Object { $_.Enabled -ieq 'True' }
    $allInboundRules = $allRules | Where-Object { $_.Direction -ieq 'Inbound' }
    $allOutboundRules = $allRules | Where-Object { $_.Direction -ieq 'Outbound' }

    $fwGroupNames = $allRules.DisplayGroup | Sort-Object -Unique 

    $mergeFile += 'DC: ' + $dc
    $mergeFile += '<--->'
    $mergeFile += 'All Enabled Rules - ' + $allRules.Count
    $mergeFile += 'All Inbound Rules - ' + $allInboundRules.Count
    $mergeFile += 'All Outbound Rules - ' + $allOutboundRules.Count
    $mergeFile += 'List Enabled Firewall Groups'
    $mergeFile += '<--->'
    $mergeFile += $fwGroupNames
    $mergeFile += '<--->'

    foreach ($fwGrp in $fwGroupNames) {
        $mergeFile += $fwGrp
        $mergeFile += Get-FirewallGroupRules($fwGrp)
    }

    $mergeFile | Out-File -FilePath $filePath

    Exit-PSSession
}
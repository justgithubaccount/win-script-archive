Clear-Host

$domainName = (Get-ADDomain).DNSRoot
$listDC = Get-ADDomainController -Filter * -Server $domainName | Select-Object HostName

foreach ($dc in $listDC.HostName) {

    Write-Host "Установка связи c $dc"

    $dcSync = New-PSSession -ComputerName $dc

    Enter-PSSession -Session $dcSync

    Invoke-Command -Session $dcSync { $a = (Get-NetIPAddress).IPAddress}
    Invoke-Command -Session $dcSync { $b = (Get-DnsClientServerAddress).ServerAddresses}
    
    Remove-PSSession $dcSync

Write-Host "Конец связи c $dc"
}
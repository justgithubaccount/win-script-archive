Clear-Host

$computers = Get-ADComputer -Filter 'Operatingsystem -notlike "*server*" -and Enabled -eq "true"' -Properties Name, Operatingsystem, OperatingSystemVersion, IPv4Address, ms-Mcs-AdmPwd
$lapsInstalledCount = 0

foreach ($computer in $computers) {
    if (Get-Member -InputObject $computer -name "ms-Mcs-AdmPwd" -MemberType Properties) {
        Sort-Object -InputObject $computer -Property Operatingsystem |
        Select-Object -Property Name, Operatingsystem, OperatingSystemVersion, IPv4Address
        $lapsInstalledCount++
    }
}
Write-Host 'Data:'
Write-Host 'Кол-во компов в домене -' $computers.Count
Write-Host 'Кол-во компов с LAPS -' $lapsInstalledCount
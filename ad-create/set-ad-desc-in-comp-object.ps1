# Получить имя компа
$curHostName = $env:computername

# Получить IP адрес
$env:HostIP = (
    Get-NetIPConfiguration |
        Where-Object {
            $_.IPv4DefaultGateway -ne $null -and
            $_.NetAdapter.Status -ne "Disconnected"
        }
    ).IPv4Address.IPAddress

# Получить DistinguishedName - CN=Administrator,CN=Users,DC=corp,DC=justmail,DC=online
$curDisName=(Get-ADUser $env:UserName -Properties *).DistinguishedName

# Получаем sAMAccountName - Administrator
$curAccName = (Get-ADUser $env:UserName -Properties *).sAMAccountName

# Получаем атрибут lastLogon
$lastLogonTime = (Get-ADUser $env:UserName -Properties *).LastLogon

# Добавляем + 3 часа от Гринвича
$lastLogonTime = (Get-Date $lastLogonTime).AddHours(+3)

# Заданием атрибутов для компьютера в AD с которым взаимодействует пользователь
$ADComp = Get-ADComputer -Identity $curHostName

# Вкладка "Управляется" в объекте компьютер
$ADComp.ManagedBy = $curDisName

# Поле "Описание" в объекте компьютер - Administrator | 10.10.15.10 | 03/03/0422 08:32:57 (MSK)
$ADComp.description = $curAccName + " | " + $env:HostIP + " | " + $lastLogonTime + " (MSK)"
Set-ADComputer -Instance $ADComp
# https://itluke.online/2018/11/27/how-to-display-firewall-rule-ports-with-powershell/

Clear-Host

function Get-FirewallGroupRules ($fwGroup) {
    Get-NetFirewallRule -DisplayGroup $fwGroup |
    Format-Table -Property Name,
    DisplayName,
    DisplayGroup,
    @{Name = 'Protocol'; Expression = { ($_ | Get-NetFirewallPortFilter).Protocol } },
    @{Name = 'LocalPort'; Expression = { ($_ | Get-NetFirewallPortFilter).LocalPort } },
    @{Name = 'RemotePort'; Expression = { ($_ | Get-NetFirewallPortFilter).RemotePort } },
    @{Name = 'RemoteAddress'; Expression = { ($_ | Get-NetFirewallAddressFilter).RemoteAddress } },
    Enabled,
    Profile,
    Direction,
    Action
}

# mDNS - Multicast DNS
Get-FirewallGroupRules('mDNS')

# Active Directory
# Get-FirewallGroupRules('Доменные службы Active Directory')
# Get-FirewallGroupRules('Веб-службы Active Directory')
# Get-FirewallGroupRules('Центр распространения ключей Kerberos')
# Get-FirewallGroupRules('Управление DFS')
# Get-FirewallGroupRules('Репликация DFS')
# Get-FirewallGroupRules('Служба DNS')

# Удаленое управленик (WinRM, etc)
# Get-FirewallGroupRules('Удаленное управление Windows')
# Get-FirewallGroupRules('Инструментарий управления Windows (WMI)')
# Get-FirewallGroupRules('Удаленное управление файловым сервером')

# Network
# Get-FirewallGroupRules('Основы сетей')
# Get-FirewallGroupRules('Дистанционное управление рабочим столом')

# Other
# Get-FirewallGroupRules('Маршрутизатор AllJoyn')
# Get-FirewallGroupRules('Общий доступ к файлам и принтерам')
# Get-FirewallGroupRules('Оптимизация доставки')
# Get-FirewallGroupRules('Сервер протоколов DIAL')
# Get-FirewallGroupRules('Репликация файлов')
# Get-FirewallGroupRules('Служба распространения ключей (Майкрософт)')

# To Disable [???]
# Get-FirewallGroupRules('Ваша учетная запись')
# Get-FirewallGroupRules('Веб-средство просмотра классических приложений')
# Get-FirewallGroupRules('Кортана')
# Get-FirewallGroupRules('Удаленное управление файловым сервером')
# Get-FirewallGroupRules('Учетная запись компании или учебного заведения')
# Get-FirewallGroupRules('Функция "Передать на устройство"')
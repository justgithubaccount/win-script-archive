Clear-Host

# Полезные ссылочки
# https://adsecurity.org/?p=3377 - Securing Domain Controllers to Improve Active Directory Security
# https://adsecurity.org/?p=3299 - Securing Windows Workstations: Developing a Secure Baseline
# https://medium.com/@cryps1s/endpoint-isolation-with-the-windows-firewall-462a795f4cfb

# https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements
# https://learn.microsoft.com/ru-RU/troubleshoot/windows-server/identity/restrict-ad-rpc-traffic-to-specific-port

# https://strontic.github.io/

# Список групп фаервола (на основе регулярок, ^ - говорит о том вхождение начинается с этого значени)
$fwDisGroups = @(
    '^@FirewallAPI.dll,-36001',                          # Функция "Передать на устройство" | Cast to Device functionality
    '^@FirewallAPI.dll,-37101',                          # Сервер протоколов DIAL | DIAL protocol server
    '^@FirewallAPI.dll,-37002',                          # Маршрутизатор AllJoyn | AllJoyn Router

    '^DiagTrack',                                        # DiagTrack (Функциональные возможности для подключенных пользователей и телеметрия)
    '^Shell Input Application'                           # Shell Input Application (создается под каждого пользователя зашедшего на комп/сервер/кд)

    '^@{Microsoft.LockApp',                              # Экран блокировки Windows по умолчанию (создается под каждого пользователя зашедшего на комп/сервер/кд)
    '^@{Microsoft.AccountsControl',                      # Электронная почта и учетные записи (создается под каждого пользователя зашедшего на комп/сервер/кд)
    '^@{Microsoft.AAD.BrokerPlugin',                     # Учетная запись компании или учебного заведения (создается под каждого пользователя зашедшего на комп/сервер/кд)
    '^@{Microsoft.Windows.Narrator',                     # Быстрый запуск экранного диктора (создается под каждого пользователя зашедшего на комп/сервер/кд)
    '^@{Microsoft.Win32WebViewHost',                     # Веб-средство просмотра классических приложений (создается под каждого пользователя зашедшего на комп/сервер/кд)
    '^@{Microsoft.Windows.CloudExperienceHost',          # Ваша учетная запись (создается под каждого пользователя зашедшего на комп/сервер/кд)
    '^@{Microsoft.Windows.Cortana'                       # Кортана (создается под каждого пользователя зашедшего на комп/сервер/кд)
    '^@{Microsoft.Windows.ShellExperienceHost'           # Windows Shell Experience (создается под каждого пользователя зашедшего на комп/сервер/кд)
    '^@{Microsoft.Windows.PeopleExperienceHost'          # Windows Shell Experience (создается под каждого пользователя зашедшего на комп/сервер/кд)
    '^@{Microsoft.Windows.Apprep.ChxApp'                 # [?] SmartScreen Защитника Windows (создается под каждого пользователя зашедшего на комп/сервер/кд)
    '^@{Microsoft.Windows.SecHealthUI'                   # Безопасность Windows (создается под каждого пользователя зашедшего на комп/сервер/кд)
    '^@{Microsoft.Windows.OOBENetworkCaptivePortal'      # Поток портала авторизации (создается под каждого пользователя зашедшего на комп/сервер/кд)
)

# Пустой массив со списком отключаемых правил фаервола полученных из групп фаервола
$disRules = @()

# Список всех включенных правил на хосте
$allRules = Get-NetFirewallRule | Where-Object {$_.Enabled -ieq 'True'}

# Получаем список отключаемых правил на основе групп
foreach ($fwGrp in $fwDisGroups) {
    $disRules += $allRules | Where-Object {$_.Group -Match $fwGrp}

}

# Отключаем правила (раскомментировать)
# $disRules | Set-NetFirewallRule -Enabled False
# Настройка TLS 1.2 для текущего сеанса PowerShell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$apiKey = ""
$apiSecret = ""
$encodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $apiKey, $apiSecret)))

# Параметры для запроса на поиск пользователей на сайте MF
$apiParametersForSearch = @{
    Uri         = 'https://api.multifactor.ru/users'
    Headers     = @{ 'Authorization' = "Basic $encodedCredentials" }
    Method      = 'GET'
    ContentType = 'application/json; charset=utf-8'
}

# Функция для получения только пользователей из AD группы
function GetAdGroup($adGroup) {
    Get-ADGroupMember -Identity $adGroup | 
    Where-Object objectClass -eq 'user' | 
    Get-ADUser -Properties * | 
    Select-Object SAMAccountName
}

# Дата которая была 60 дней назад, в UTC формате '2021-09-06T21:00:00.000Z'
$dateFormat = 'yyyy-MM-dd'
$60DaysAgo = (Get-Date).AddDays(-60)
$utcDate = (Get-Date -Date $60DaysAgo -Format $dateFormat) + 'T10:00:00.000Z'

# Список исключениЙ (учетные записи не будут учитыватся в выполнение скрипта)
$lstExclude = GetAdGroup('VpnExcludeList')
# Отправка запроса с сайту MF для получения всех пользователей
$lstMfUsers = Invoke-RestMethod @apiParametersForSearch
# Список пользователей с сайта MF (учитывая список исключений)
$lstMfUsersFilter = $lstMfUsers.model | Where-Object { $lstExclude.SAMAccountName -notcontains $_.identity }
# Список пользователей с сайта MF (не заходивших 60 дней и не имеющие данные о последнем входе)
$lstMfRemoveUsers = $lstMfUsersFilter | Where-Object { ($_.lastLogin -lt $utcDate) -and ($_.lastLogin -ne $null) }
# Список всех NTW_VPN групп 
$lstAdGroupFromNtwOu = (Get-ADGroup -Filter * -SearchBase "OU=VPN Security groups,OU=VPN,OU=domain,DC=domain,DC=ru" -Properties *).Name

# Параметры сохранения лог-файла
$runTime = Get-Date
$filePath = "\\domain.ru\logs\ntw-vpn-mf-users-sync\mf-report-tst.log"
$mergeFile = @()

$mergeFile += '### Список удаленных пользователей с сайта multifactor.ru (' + $runTime + ')'
$mergeFile += "### Имя пользователя (последний вход | время создания учетной записи)"
$mergeFile += '# Кол-во пользователей MF (общее) - ' + $lstMfUsers.model.Count
$mergeFile += '# Кол-во пользователей MF (с учетом исключений (' + $lstExclude.Count + ')) - ' + $lstMfUsersFilter.Count
$mergeFile += '# Кол-во удаленных пользователей MF - ' + $lstMfRemoveUsers.Count

foreach($userMf in $lstMfRemoveUsers) {
    $mergeFile += '[mf] ' + $userMf.identity + ' (' + $userMf.lastLogin + ' | ' + $userMf.createdAt + ')' 
}

# Удаляем пользователей по ID (раскомментить последнюю строку)
foreach ($id in $lstMfRemoveUsers.id) {
    $apiParametersForDelete = @{
        Uri         = "https://api.multifactor.ru/users/$id"
        Headers     = @{ 'Authorization' = "Basic $encodedCredentials" }
        Method      = 'DELETE'
        ContentType = 'application/json; charset=utf-8'
    }
    # Invoke-RestMethod @apiParametersForDelete
}

$mergeFile += '### Список удаленных пользователей в Active Directory'

# Поиск удаленых пользователей с сайта MF в AD (во всех NTW_VPN группах)
foreach ($adNtwGroup in $lstAdGroupFromNtwOu) {
    $remUserAdCounter = 0
    # Получаем список пользователей NTW_VPN группы
    $lstAdNtwMembers = GetAdGroup($adNtwGroup)
    $mergeFile += '## ' + $adNtwGroup
    # Сравниваем список удаленых с сайта MF ($mfRemoveUser) со списком пользователей группы NTW_VPN ($adNtwMember)
    foreach ($mfRemoveUser in $lstMfRemoveUsers.identity) {
        foreach ($adNtwMember in $lstAdNtwMembers.SAMAccountName) {
            # Если произошоло совпадение удаляем пользователя из группы NTW_VPN
            if ($mfRemoveUser -ieq $adNtwMember) {
                $remUserAdCounter++
                $mergeFile += '[ad] ' + $adNtwMember
                # Remove-ADGroupMember -Identity $adNtwGroup -Members $adNtwMember -Confirm:$false
            }
        }
    }
    $mergeFile += '# Кол-во удаленных - ' + $remUserAdCounter
}

# Сохранение лог-файла
$mergeFile | Out-File -FilePath $filePath
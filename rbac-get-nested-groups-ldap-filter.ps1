Clear-Host

# Получить список всех групп пользователя

$username = 'tst-vpupkin'
$dn = (Get-ADUser $username).DistinguishedName
Get-ADGroup -LDAPFilter ("(member:1.2.840.113556.1.4.1941:={0})" -f $dn) | Select-Object -expand Name | Sort-Object Name
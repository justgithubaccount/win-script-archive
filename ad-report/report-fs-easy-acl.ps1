Clear-Host

$fsPath = '\\domain.ru\fs\'

$groupScope = Get-Acl -Path $fsPath

# Владелец
Write-Host 'Владелец:'
Write-Host
$groupScope.Owner

# ACL (Список доступа)
Write-Host 'ACL (список доступа):'
Write-Host 
$groupScope.Access.IdentityReference.Value
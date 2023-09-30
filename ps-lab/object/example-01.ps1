Clear-Host

# https://learn.microsoft.com/ru-ru/powershell/scripting/learn/deep-dives/everything-about-pscustomobject?view=powershell-7.3

$permReport = [PSCustomObject]@{
    Group   = 'Permission'
    Members = 'Users'
    Note    = ':)'
}

$permReport.Group
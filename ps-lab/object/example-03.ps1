Clear-Host

# https://www.reddit.com/r/PowerShell/comments/75pgpw/help_creating_custom_objects/

# $users = get-aduser -Filter {department -like "*licensing*"} -Properties title, department

$lstDisabled = Search-ADAccount -UsersOnly -AccountDisabled | Select-Object SamAccountName, userPrincipalName

$result = foreach ($user in $lstDisabled) {
    [pscustomobject]@{
        userPrincipalName = $user.userPrincipalName
        SamAccountName    = $user.SamAccountName
        #$Department = $user.Name.Replace(" ", "")
    }
}

$result
Clear-Host

# https://www.reddit.com/r/PowerShell/comments/75pgpw/help_creating_custom_objects/

$lstDisabled = Search-ADAccount -UsersOnly -AccountDisabled | Select-Object SamAccountName, userPrincipalName
# $GetUsers = get-aduser -Filter {department -like "*licensing*"} -Properties title, department; 
$output = @() # array to hold each object from foreach loop

foreach ( $getuser in $lstDisabled ) { 

    $obj = New-Object -TypeName psobject -Property @{
        Name       = $getuser.SamAccountName
        Title      = $getuser.userPrincipalName
        # Department = $getuser.department
    } #  $obj = New-Object -TypeName psobject -Property @{

    $output += $obj # adds $obj to output array

} # foreach ( $getuser in $Getusers ) { 

$output # show the output array
Clear-Host

# https://stackoverflow.com/questions/54661402/how-to-dynamically-add-new-properties-to-custom-object-in-powershell

$o = [pscustomobject]@{
    MemberA = 'aaa'
    MemberB = 'bbb'
    MemberC = 'ccc'
    MemberD = 'ddd'
}

"Before"
$o | Format-Table

$o | Add-Member -MemberType NoteProperty -Name 'MemberE' -Value 'eee'
$o | Add-Member -MemberType NoteProperty -Name 'MemberF' -Value 'fff'
$o | Add-Member -MemberType NoteProperty -Name 'MemberG' -Value 'ggg'

"After"
$o | Format-Table

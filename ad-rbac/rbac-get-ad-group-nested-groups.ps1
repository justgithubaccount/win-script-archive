Function Get-ADNestedGroups {
    param($Members)

    foreach ($member in $Members) {
        $out = Get-ADGroup -filter "DistinguishedName -eq '$member'" -properties members
        $out | Select-Object Name
        Get-ADNestedGroups -Members $out.Members
    }
}

$group = "CMP_Group"
$members = (Get-ADGroup -Identity $group -Properties Members).Members

Write-Output Get-ADNestedGroups $members
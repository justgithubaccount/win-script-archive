$filePath = "\\domain.ru\logs\cmp-mng-report\$env:computername.txt"

$mergeFile = @()

foreach ($grp in (Get-LocalGroup)) {
    foreach ($member in (Get-LocalGroupMember -Group $grp)) {
        
        $addMemArgs = @{
            MemberType = "NoteProperty"
            Name = "GroupName"
            Value = $grp.Name
            PassThru = $true
        }
        $selectProps = @(
            'GroupName', 'Name', 'PrincipalSource', 'ObjectClass'
        )

        $mergeFile += $member | Add-Member @addMemArgs | Select-Object $selectProps 
    }
}

$mergeFile | Out-File -FilePath $filePath
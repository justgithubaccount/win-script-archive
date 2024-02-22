Clear-Host

# Модуль для PS (AD) - https://github.com/EvotecIT/ADEssentials
Install-Module -Name ADEssentials -AllowClobber -Force
# Обновить - Update-Module -Name ADEssentials
# Мини-обзор - https://web.archive.org/web/20221205215824/https://evotec.xyz/visually-display-active-directory-nested-group-membership-using-powershell/

# Модуль для PS (Excel) - https://github.com/dfinke/ImportExcel
Install-Module -Name ImportExcel
# Мини-обзор - https://dfinke.github.io/powershell/2019/07/31/Creating-beautiful-Powershell-Reports-in-Excel.html

# LDAP-фильтр для поиска групп начинающихся с $typePerm
$typePerm = "APL_"
$ldapOut = Get-ADGroup -LDAPFilter ("(&(objectCategory=group)(name=$typePerm*))") | Select-Object -Expand Name

# Параметры для Get-WinADGroupMember (Select-Object)
$selectProps = @(
    'SamAccountName', 'Name', 'DisplayName', 'ParentGroup', 'Enabled', 'Sid'
)

# Путь сохранения файла (перезапись каждый раз при выполнение)
$xlfile = ".\$typePerm.xlsx"
Remove-Item $xlfile -ErrorAction SilentlyContinue

# Позиция (строка в Эксель) для вывода названия группы и списка ее членов
$excelStartRowGroupName = 1
$excelStartRowGroupDesc = 2
$excelStartRowNestedMembers = 3
# $tableNameCount = 1

foreach ($grp in $ldapOut) {
    $nestedMembers = Get-WinADGroupMember -Group $grp |
    # $nestedMembers = Get-WinADGroupMember -Group $grp -AddSelf -All |
    Select-Object $selectProps |
    Sort-Object ParentGroup

    <#
    if ($nestedMembers.Count -gt 0) {
        $excel = $nestedMembers | Export-Excel $xlfile -AutoSize -StartRow $excelStartRowNestedMembers -PassThru # -TableName "ReportPermission$tableNameCount"
    } elseif ($nestedMembers.Count -eq 0) {
        $excel = $nestedMembers | Export-Excel $xlfile -StartRow $excelStartRowNestedMembers -PassThru # -TableName "ReportPermission$tableNameCount"
    }
    #>

    $excel = $nestedMembers | Export-Excel $xlfile -AutoSize -StartRow $excelStartRowNestedMembers -PassThru # -TableName "ReportPermission$tableNameCount"

    # Get the sheet named Sheet1
    $ws = $excel.Workbook.Worksheets['Sheet1']

    # Create a hashtable with a few properties
    # that you'll splat on Set-Format
    $xlParamsGrpName = @{WorkSheet = $ws; Bold = $true; FontSize = 18; AutoSize = $true}
    $xlParamsGrpDesc = @{WorkSheet = $ws; Bold = $false; FontSize = 14; AutoSize = $false}

    $adDesc = Get-ADGroup $grp -Properties Description | Select-Object Description

    # Create the headings in the Excel worksheet
    Set-Format -Range "A$excelStartRowGroupName" -Value $grp @xlParamsGrpName
    Set-Format -Range "A$excelStartRowGroupDesc" -Value $adDesc.Description @xlParamsGrpDesc   
    
    # Следующая позиция (строка в Эксель) для вывода названия группы
    $excelStartRowGroupName += $nestedMembers.Count + 3

    # Следующая позиция (строка в Эксель) для вывода описания группы
    $excelStartRowGroupDesc += $nestedMembers.Count + 3

    # Следующая позиция (строка в Эксель) для вывода членов группы
    $excelStartRowNestedMembers += $nestedMembers.Count + 3

    Close-ExcelPackage $excel
}
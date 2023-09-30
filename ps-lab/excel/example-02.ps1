$xlfile = ".\PSreports.xlsx"
Remove-Item $xlfile -ErrorAction SilentlyContinue

# Get-Process
Get-Process | Select -First 5 |
    Export-Excel $xlfile -AutoSize -StartRow 2 -TableName ReportProcess

# Get-Service
Get-Service | Select -First 5 |
    Export-Excel $xlfile -AutoSize -StartRow 11 -TableName ReportService

# Directory Listing
$excel = Get-ChildItem $env:HOMEPATH\Documents\WindowsPowerShell |
    Select PSDRive, PSIsC*, FullName, *time* |
    Export-Excel $xlfile -AutoSize -StartRow 20 -TableName ReportFiles -PassThru

# Get the sheet named Sheet1
$ws = $excel.Workbook.Worksheets['Sheet1']

# Create a hashtable with a few properties
# that you'll splat on Set-Format
$xlParams = @{WorkSheet=$ws;Bold=$true;FontSize=18;AutoSize=$true}

# Create the headings in the Excel worksheet
Set-Format -Range A1  -Value "Report Process" @xlParams
Set-Format -Range A10 -Value "Report Service" @xlParams
Set-Format -Range A19 -Value "Report Files"   @xlParams

# Close and Save the changes to the Excel file
# Launch the Excel file using the -Show switch
Close-ExcelPackage $excel -Show
Get-Process | Select-Object -Property Name,WS,CPU,Description,StartTime |
Export-Excel -Path .\demo.xlsx -Show
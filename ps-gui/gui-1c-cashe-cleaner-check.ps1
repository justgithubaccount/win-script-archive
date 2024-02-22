Add-Type -AssemblyName System.Windows.Forms

$ClearCashe1C                    = New-Object system.Windows.Forms.Form
$ClearCashe1C.ClientSize         = New-Object System.Drawing.Point(425,322)
$ClearCashe1C.text               = "Очистка кэша 1С"
$ClearCashe1C.TopMost            = $false

$WarningText                     = New-Object system.Windows.Forms.Label
$WarningText.text                = "Перед очисткой кэша необходимо закрыть все открытые 1С"
$WarningText.AutoSize            = $true
$WarningText.width               = 25
$WarningText.height              = 10
$WarningText.location            = New-Object System.Drawing.Point(8,8)
$WarningText.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$WarningText.ForeColor           = [System.Drawing.ColorTranslator]::FromHtml("#d0021b")

$СlearSaveButton                 = New-Object system.Windows.Forms.Button
$СlearSaveButton.text            = "Очистка кэша 1С с сохранением настроек"
$СlearSaveButton.width           = 410
$СlearSaveButton.height          = 140
$СlearSaveButton.location        = New-Object System.Drawing.Point(8,30)
$СlearSaveButton.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$FullClear                       = New-Object system.Windows.Forms.Button
$FullClear.text                  = "Очистка кэша 1С без сохранения настроек"
$FullClear.width                 = 410
$FullClear.height                = 140
$FullClear.location              = New-Object System.Drawing.Point(8,175)
$FullClear.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$ClearCashe1C.controls.AddRange(@($WarningText, $СlearSaveButton,$FullClear))

$СlearSaveButton.Add_Click({ 
    try {
        # Путь до файла ibases.v8i со списком всех баз подключенных у пользователя
        $ibases = "$ENV:USERPROFILE\AppData\Roaming\1C\1CEStart\ibases.v8i"

        # Формирование из файла одной текстовой строки
        $StringText = (Get-Content $ibases) -Join ''

        # Нахождение guid базы ERP
        $RegExGUID = 'S-1C-TVR-01;Ref="ERP";ID=[a-z0-9]{8}(?:-[a-z0-9]{4}){3}-[a-z0-9]{12}'

        $StringText -match $RegExGUID

        $matches[0] -match '[a-z0-9]{8}(?:-[a-z0-9]{4}){3}-[a-z0-9]{12}'

        $ERPPath = "$ENV:USERPROFILE\AppData\Local\1C\1Cv8\" + $matches[0]

        echo $ERPPath

        # Очистка кэша ERP

        if (Test-Path $ERPPath) {
            Remove-Item $ERPPath -Force -Recurse
        } 
      
        # Очистка кэша баз не относящихся ERP
        $Config = "$ENV:USERPROFILE\AppData\Local\1C\1Cv8\*\Config"
        $ConfigSave = "$ENV:USERPROFILE\AppData\Local\1C\1Cv8\*\ConfigSave"

        if ((Test-Path $Config) -or (Test-Path $ConfigSave)) {
            Remove-Item $Config -Force -Recurse
	        Remove-Item $ConfigSave -Force -Recurse
            Get-ChildItem "$ENV:USERPROFILE\AppData\Roaming\1C\1Cv8\*" | Where {$_.Name -as [guid]} | Remove-Item -Force -Recurse
        } 

        [System.Windows.MessageBox]::Show('Кэш 1С успешно очищен :)')

    } catch {
        [System.Windows.MessageBox]::Show('Что-то пошло не так :(')
    }
})

$FullClear.Add_Click({
    try {
        Get-ChildItem "$ENV:USERPROFILE\AppData\Local\1C\1Cv8\*","$ENV:USERPROFILE\AppData\Roaming\1C\1Cv8\*" | Where {$_.Name -as [guid]} | Remove-Item -Force -Recurse
        [System.Windows.MessageBox]::Show('Кэш 1С успешно очищен :)')
    } catch {
        [System.Windows.MessageBox]::Show('Что-то пошло не так :(')
    }
})

$CenterScreen = [System.Windows.Forms.FormStartPosition]::CenterScreen;
$ClearCashe1C.StartPosition = $CenterScreen;

$ClearCashe1C.FormBorderStyle    = 'Fixed3D'
$ClearCashe1C.MaximizeBox        = $false
$ClearCashe1C.ShowDialog()
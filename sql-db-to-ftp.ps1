# Скрипт находит последний .bak файл в папке с бэкапами и закачивает его на FTP c нужным именем

# Подключаем модуль для взаимодействия с FTP
# https://gallery.technet.microsoft.com/scriptcenter/PowerShell-FTP-Client-db6fe0cb
Import-Module PSFTP

# Данные для подклчюения
$fptHost = 'sub.domain.ru'
$ftpLogin = 'domain.com'
$ftpPass = 'password'
$secFtpPass = ConvertTo-SecureString $ftpPass -Force -AsPlainText
$cred = New-Object Management.Automation.PSCredential($ftpLogin, $secFtpPass)

# Название базы данных
$dbName = 'db-name'

# Откуда и куда нужно скопировать базу данных
$pathFrom = 'C:\MSSQL_Backups\dbs'
$pathTo = '/folder-on-ftp/backup_dbs/'

# Подключаемся к FTP
Set-FTPConnection -Server $fptHost -UseBinary -UsePassive -Session BackupTransfer -Credential $cred
$Session = Get-FTPConnection -Session BackupTransfer

# Получаем последний бэкап на сегодня
$lastBackup = Get-ChildItem $pathFrom '*.bak' | Where-Object { $_.LastWriteTime -gt (Get-Date).Date }

# Закачиваем файл на FTP
$lastBackup | Add-FTPItem -Session $Session -Path $pathTo

# Переименовываем файл на FTP
$renamePath = $pathTo + $lastBackup.Name
$fileNameOnFtp = $dbName + '_backup.bak'
Rename-FTPItem -Session $Session -Path $renamePath -NewName $fileNameOnFtp
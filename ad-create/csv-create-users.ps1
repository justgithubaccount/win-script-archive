Import-Csv "C:\users.csv" -Delimiter ";" | ForEach-Object {

    # Формируем UPN имя
    $upn = $_.SamAccountName + “@domain.com”
    
    # Формируем ФИО 
    $uname = $_.LastName + " " + $_.FirstName + " " + $_.SurName
    
    # Путь на файловом сервере куда сохранить файл с логином и паролем
    $pathOnFS = "\\domain.com\fs\it\new-user\$uname.txt"
    
    # Задаем необходимые параметры
    New-ADUser -PasswordNeverExpires $True -CannotChangePassword $true -Name $uname `
        -DisplayName $uname `
        -GivenName $_.FirstName `
        -Surname $_.LastName `
        -OfficePhone $_.Phone `
        -Department $_.Department `
        -Title $_.JobTitle `
        -UserPrincipalName $upn `
        -SamAccountName $_.samAccountName `
        -Path $_.OU `
        -City $_.City `
        -AccountPassword (ConvertTo-SecureString $_.Password -AsPlainText -force) -Enabled $true
    
    # Создаем файл на файловом сервере с логином и паролем
    New-Item $pathOnFS
    
    # Добавляем логин и пароль
    Add-Content $pathOnFS $_.uname
    Add-Content $pathOnFS $_.Department
    Add-Content $pathOnFS $_.JobTitle
    Add-Content $pathOnFS $_.Phone
}
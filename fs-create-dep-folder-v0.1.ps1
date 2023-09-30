Import-Module ActiveDirectory

# Заготовка для корневой папки отдела (для каждого нового отдела)

# Перед запуском необходимо создать корневую папку отдела department и настройть только NTFS права

# ABE_FS_department_L (чтение, только для этой папки)
# СИСТЕМА (Полный доступ)
# Локальные администраторы (Полный доступ)

#######################
# Config Script Begin #
#######################

# Корневая папка 
$rootFolder = "department"

# Название ABE группы в корневой папке отдела
$rootDepABE = "ABE_FS_department_L"

# Сетевой путь до корневой папки отдела
$sharePath = "\\domain.ru\fs\department\"

# Название подразделения которое необходимо создать в корневой папке
$shareFolderName = "ТО"

# Задержка выполнения скрипта при установке разрешений
$sleepTime = 0

# Приставка (NetBios) к названию групп
$prefixNetBios = "domain\"

# Костыль | "СИСТЕМА" и "BUILTIN\Администраторы" для системы на русском языке | "SYSTEM" и "BUILTIN\Administrators" для системы на англ. языке
$langSystem = "СИСТЕМА"
$langAdmin = "BUILTIN\Администраторы"

# Путь до OU c ресурсными группами
$pathLocal = "OU=FS,OU=Permissions,OU=Groups,OU=Assn,DC=domain,DC=ru"

#####################
# Config Script End #
#####################

# Формирование названий для ресурсных групп

# ACL_department_subdepartment_R
$localGroupNameRO = "ACL_" + $rootFolder + "_" + $shareFolderName + "_R"

# ACL_department_subdepartment_RW
$localGroupNameRW = "ACL_" + $rootFolder + "_" + $shareFolderName + "_RW"

# REM_department_subdepartment_D
$localGroupNameD = "REM_" + $rootFolder + "_" + $shareFolderName + "_D"

# Формирование описаний для ресурсных групп

# [Чтение] \\domain.ru\fs\department\ТО
$descR = "[Чтение]" + " " + $sharePath + $shareFolderName

# [Чтение + Запись] \\domain.ru\fs\department\ТО
$descRW = "[Чтение + Запись]" + " " + $sharePath  + $shareFolderName

# Запрет удаления папки ТО группе с правами RW
$descD = "Запрет удаления папки " + $shareFolderName + " группе с правами RW"

# Создадние ресурсных групп
New-ADGroup -Name $localGroupNameRO -Description $descR -GroupScope DomainLocal -GroupCategory Security -Path $pathLocal
New-ADGroup -Name $localGroupNameRW -Description $descRW -GroupScope DomainLocal -GroupCategory Security -Path $pathLocal
New-ADGroup -Name $localGroupNameD -Description $descD -GroupScope DomainLocal -GroupCategory Security -Path $pathLocal

# Добавление в члены группы ABE_FS_department_L группы ACL_department_subdepartment_R и ACL_department_subdepartment_RW
Add-ADGroupMember -Identity $rootDepABE -Members $localGroupNameRO, $localGroupNameRW
# Добавление в члены группы REM_department_subdepartment_D группы ACL_department_subdepartment_RW
Add-ADGroupMember -Identity $localGroupNameD -Members $localGroupNameRW

# Полный путь до созданной папки отдела - \\domain.ru\fs\department\ТО
$shareFolderName = $sharePath + $shareFolderName

# Добавляем приставку "domain\" (NetBios) к названию групп
$localGroupNameRO = $prefixNetBios + $localGroupNameRO
$localGroupNameRW = $prefixNetBios + $localGroupNameRW
$localGroupNameD = $prefixNetBios + $localGroupNameD

# Создаем папку отдела
New-Item -Path $shareFolderName -ItemType Directory

Start-Sleep -Seconds $sleepTime

# Настройка разрешений

# Подробнее о настройке - https://www.sysadmins.lv/blog-ru/upravlenie-acl-v-powershell-chast-2.aspx

# Получаем текущий список ACL у созданной папки отдела
$ACL = Get-ACL -Path $shareFolderName

Start-Sleep -Seconds $sleepTime

# Отключение наследования для созданной папки отдела
$ACL.SetAccessRuleProtection($True, $False)

Start-Sleep -Seconds $sleepTime

# Удаляем все ACE, которые были оставлены после снятия наследования
($ACL).Access | ForEach-Object {$ACL.PurgeAccessRules($_.IdentityReference)}

Start-Sleep -Seconds $sleepTime

# Добавляем субъект NT AUTHORITY\СИСТЕМА с правом FullControl для папки ТО ее подпапок и файлов (CI, OI, None)
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($langSystem, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$ACL.AddAccessRule($AccessRule)

Start-Sleep -Seconds $sleepTime

# Добавляем субъект BUILTIN\Администраторы с правом FullControl для папки ТО ее подпапок и файлов (CI, OI, None)
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($langAdmin, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$ACL.AddAccessRule($AccessRule)

Start-Sleep -Seconds $sleepTime

# Добавляем субъект ACL_department_subdepartment_RO с правом ReadAndExecute для папки ТО ее подпапок и файлов (CI, OI, None)
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($localGroupNameRO, "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
$ACL.AddAccessRule($AccessRule)

Start-Sleep -Seconds $sleepTime

# Добавляем субъект ACL_department_subdepartment_RW с правом DeleteSubdirectoriesAndFiles, Modify только для подпапок и Файлов в папке ТО (CI, OI, IO)
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($localGroupNameRW, "DeleteSubdirectoriesAndFiles, Modify", "ContainerInherit, ObjectInherit", "InheritOnly", "Allow")
$ACL.AddAccessRule($AccessRule)

Start-Sleep -Seconds $sleepTime

# Добавляем субъект REM_department_subdepartment_D с правом DeleteSubdirectoriesAndFiles, Write, ReadAndExecute только для папки ТО (без дополнительных параметров)
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($localGroupNameD, "DeleteSubdirectoriesAndFiles, Write, ReadAndExecute", "Allow")
$ACL.AddAccessRule($AccessRule)

Start-Sleep -Seconds $sleepTime

# Устанавливаем разрешение для созданной папки
Set-ACL -Path $shareFolderName -ACLObject $ACL
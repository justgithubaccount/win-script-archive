# Запуск скрипта каждый день в 10:00
# AtStartup
$Trigger = New-ScheduledTaskTrigger -At 10:00am -Daily
$User = "NT AUTHORITY\СИСТЕМА"
$Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "\\domain.ru\cfg\sheduled-task\mf-ad-sync.ps1"
Register-ScheduledTask -TaskName "AD_MF Sync" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force

# Get-ScheduledTask CheckServiceState_PS| Get-ScheduledTaskInfo

# Start-ScheduledTask CheckServiceState_PS

# $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument “-NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File C:\PS\StartupScript.ps1"
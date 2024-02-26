param(
    [string]$BACKUP_DIR
)

$taskName = "Gitea Backup"
$scriptPath = (Get-Location).Path
$scriptName = "backup.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 4am
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath\$scriptName`" $BACKUP_DIR"
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -InputObject $task
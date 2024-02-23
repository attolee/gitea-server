# 定义任务名，脚本路径和脚本文件名
$taskName = "BackupTask"
$scriptPath = (Get-Location).Path
$scriptName = "backup.ps1"

# 创建触发器
$trigger = New-ScheduledTaskTrigger -Daily -At 4am

# 创建操作
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File $scriptPath\$scriptName"

# 创建主体
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive

# 创建任务
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger

# 注册任务
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -InputObject $task
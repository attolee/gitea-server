param (
    [string]$BACKUP_FILE
)

if (-not $BACKUP_FILE) {
    $BACKUP_FILE = Read-Host -Prompt "请输入备份文件路径"
}

if ((Test-Path -Path $BACKUP_FILE -PathType Leaf) -eq $false) {
    Write-Error "提供的备份文件不是一个文件。"
    exit 1
}

if (-not $BACKUP_FILE) {
    Write-Error "备份文件路径不能为空"
    exit 1
}

if (-not (Test-Path -Path $BACKUP_FILE)) {
    Write-Error "备份文件不存在"
    exit 1
}

$IS_GITEA_RUNNING = docker ps --format "{{.Names}}" | Select-String -Pattern "^gitea$"
if (-not $IS_GITEA_RUNNING) {
    Write-Error "Gitea 未运行，请先启动 Gitea"
    exit 1
}

Write-Host '恢复 Gitea 数据库中...'
docker exec -u root -it mysql /bin/bash -c "rm -rf /tmp/*"
Expand-Archive -Path $BACKUP_FILE -DestinationPath ./tmp
docker cp ./tmp/gitea-db.sql mysql:/tmp/gitea-db.sql
$USER = "gitea"
$PASSWORD = "gitea"
$DATABASE = "gitea"
docker exec -u root -it -w /tmp mysql /bin/bash -c "mysql --default-character-set=utf8mb4 -u$USER -p$PASSWORD $DATABASE < gitea-db.sql"

# https://github.com/go-gitea/gitea/issues/23964#issuecomment-1500105529
Write-Host '恢复 Gitea 仓库中...'
docker exec -u root -it gitea /bin/bash -c "rm -rf /tmp/*"
docker cp $BACKUP_FILE gitea:/tmp/gitea-dump.zip
docker exec -u root -it gitea /bin/bash -c "unzip /tmp/gitea-dump.zip -d /tmp/gitea-dump"
docker exec -u root -it gitea /bin/bash -c "cp -rf /tmp/gitea-dump/data/* /data/gitea"
docker exec -u root -it gitea /bin/bash -c "cp -rf /tmp/gitea-dump/repos/* /data/git/repositories/"
docker exec -u root -it gitea /bin/bash -c "chown -R git:git /data"
docker exec -u git -it gitea /bin/bash -c "/usr/local/bin/gitea -c '/data/gitea/conf/app.ini' admin regenerate hooks"

Write-Host '清理临时文件...'
Remove-Item -Path ./tmp -Recurse -Force

Write-Host '恢复完成，重启 Gitea...'
docker compose restart
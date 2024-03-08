param(
    [string]$BACKUP_DIR
)

if (-not $BACKUP_DIR) {
    $BACKUP_DIR = "./backup"
}

if (-not (Test-Path -Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR
}

docker exec -u root -w /tmp gitea /bin/bash -c 'rm -rf *'
docker exec -u git -w /tmp gitea /bin/bash -c '/usr/local/bin/gitea dump -c /data/gitea/conf/app.ini'
docker cp gitea:/tmp/ $HOME
Move-Item -Path $HOME/tmp/*.zip -Destination $BACKUP_DIR
Remove-Item -Path $HOME/tmp -Recurse -Force

# Keep the 5 most recent backups
Get-ChildItem -Path $BACKUP_DIR -Filter "*.zip" |
Sort-Object LastWriteTime -Descending |
Select-Object -Skip 5 |
Remove-Item -Force

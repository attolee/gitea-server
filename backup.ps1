param(
    [string]$BACKUP_DIR
)

if (-not $BACKUP_DIR) {
    $BACKUP_DIR = "./backup"
}

if (-not (Test-Path -Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR
}

docker exec -u root -it -w /tmp gitea /bin/bash -c 'rm -rf *'
docker exec -u git -it -w /tmp gitea /bin/bash -c '/usr/local/bin/gitea dump -c /data/gitea/conf/app.ini'
docker cp gitea:/tmp/ .
Move-Item -Path ./tmp/*.zip -Destination $BACKUP_DIR
Remove-Item -Path ./tmp -Recurse -Force
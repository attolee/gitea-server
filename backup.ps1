if (Test-Path -Path ./backup_url.txt) {
    $BACKUP_DIR = Get-Content -Path ./backup_url.txt
} else {
    $BACKUP_DIR = "./backup"
}
$CONTAINER_ID = $(docker ps -qf "name=^gitea$" 2>$null)
$BACKUP_NUM = 5

docker exec -u git -it -w '/tmp' $CONTAINER_ID /bin/bash -c 'rm *.zip'
docker exec -u git -it -w '/tmp' $CONTAINER_ID /bin/bash -c '/usr/local/bin/gitea dump -c /data/gitea/conf/app.ini'
docker cp ${CONTAINER_ID}:/tmp/ .
if (!(Test-Path -Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR
}
Move-Item -Path ./tmp/*.zip -Destination $BACKUP_DIR
Remove-Item -Path ./tmp -Recurse -Force

$files = Get-ChildItem -Path $BACKUP_DIR
if ($files.Count -gt $BACKUP_NUM) {
    $files | Sort-Object -Property LastWriteTime | Select-Object -First 1 | Remove-Item -Force
}

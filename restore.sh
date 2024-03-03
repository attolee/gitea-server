#!/bin/bash

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]
then
    echo "请输入备份文件路径"
    read BACKUP_FILE
fi

if [ ! -f "$BACKUP_FILE" ]
then
    echo "提供的备份文件不是一个文件。"
    exit 1
fi

if [ -z "$BACKUP_FILE" ]
then
    echo "备份文件路径不能为空"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]
then
    echo "备份文件不存在"
    exit 1
fi

IS_GITEA_RUNNING=$(docker ps --format "{{.Names}}" | grep "^gitea$")
if [ -z "$IS_GITEA_RUNNING" ]
then
    echo "Gitea 未运行，请先启动 Gitea"
    exit 1
fi

echo '恢复 Gitea 数据库中...'
docker exec -u root -it mysql /bin/bash -c "rm -rf /tmp/*"
7z x $BACKUP_FILE -o./tmp
docker cp ./tmp/gitea-db.sql mysql:/tmp/gitea-db.sql
USER="gitea"
PASSWORD="gitea"
DATABASE="gitea"
docker exec -u root -it -w /tmp mysql /bin/bash -c "mysql --default-character-set=utf8mb4 -u$USER -p$PASSWORD $DATABASE < gitea-db.sql"

echo '清理临时文件...'
rm -rf ./tmp

echo '恢复 Gitea 仓库中...'
docker exec -u root -it gitea /bin/bash -c "rm -rf /tmp/*"
docker cp $BACKUP_FILE gitea:/tmp/gitea-dump.zip
docker exec -u root -it gitea /bin/bash -c "unzip /tmp/gitea-dump.zip -d /tmp/gitea-dump"
docker exec -u root -it gitea /bin/bash -c "cp -rf /tmp/gitea-dump/data/* /data/gitea/"
docker exec -u root -it gitea /bin/bash -c "mkdir -p /data/git/repositories"
docker exec -u root -it gitea /bin/bash -c "cp -rf /tmp/gitea-dump/repos/* /data/git/repositories/"
docker exec -u root -it gitea /bin/bash -c "chown -R git:git /data"
docker exec -u git -it gitea /bin/bash -c "/usr/local/bin/gitea -c '/data/gitea/conf/app.ini' admin regenerate hooks"

echo '恢复完成，重启 Gitea...'
docker compose restart
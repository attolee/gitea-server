#!/bin/bash

BACKUP_DIR=$1

if [ -z "$BACKUP_DIR" ]
then
    BACKUP_DIR="./backup"
fi

if [ ! -d "$BACKUP_DIR" ]
then
    mkdir -p $BACKUP_DIR
fi

docker exec -u root -it -w /tmp gitea /bin/bash -c 'rm -rf *'
docker exec -u git -it -w /tmp gitea /bin/bash -c '/usr/local/bin/gitea dump -c /data/gitea/conf/app.ini'
docker cp gitea:/tmp/ .
mv ./tmp/*.zip $BACKUP_DIR
rm -rf ./tmp
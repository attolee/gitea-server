#!/bin/bash

BACKUP_DIR=$1
TASK_NAME="Gitea Backup"
SCRIPT_PATH=$(pwd)
SCRIPT_NAME="backup.sh"

# Remove old cron job
(crontab -l 2>/dev/null | grep -v -F "$SCRIPT_NAME") | crontab -

# Add new cron job
(crontab -l 2>/dev/null; echo "0 4 * * * /bin/bash $SCRIPT_PATH/$SCRIPT_NAME $BACKUP_DIR") | crontab -

# Keep only the five most recent backups
cd $BACKUP_DIR
ls -t | sed -e '1,5d' | xargs -d '\n' rm
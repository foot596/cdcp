#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

LOG_DIR="log"
LOG_FILE_CORE="$LOG_DIR/cdcp_core.log"

OLD_HEAD=$(git rev-parse HEAD)
echo "[$(date +"%d-%m-%Y %H:%M:%S")] Current revision: $OLD_HEAD" | tee -a $LOG_FILE_CORE

git pull origin master | tee -a $LOG_FILE_CORE
NEW_HEAD=$(git rev-parse HEAD)
echo "[$(date +"%d-%m-%Y %H:%M:%S")] New revision: $NEW_HEAD" | tee -a $LOG_FILE_CORE

if [ $OLD_HEAD != $NEW_HEAD ]; then
  echo "[$(date +"%d-%m-%Y %H:%M:%S")] Script updated. Restarting" | tee -a $LOG_FILE_CORE
  exec ./run.sh
fi

for CD_DEVICE in $(ls /dev/sr*); do
  echo "[$(date +"%d-%m-%Y %H:%M:%S")] Found $CD_DEVICE" | tee -a $LOG_FILE_CORE
  gnome-terminal -x ./lib/cdcp.sh $CD_DEVICE
done

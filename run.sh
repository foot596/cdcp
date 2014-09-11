#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

LOG_DIR="log"
LOG_FILE_CORE="$LOG_DIR/cdcp_core.log"

git pull | tee -a $LOG_FILE_CORE
echo "[$(date +"%d-%m-%Y %H:%M:%S")] git error code: $?" | tee -a $LOG_FILE_CORE
if [ $? -ne 0 ]; then
  echo "[$(date +"%d-%m-%Y %H:%M:%S")] Script updated. Restarting" | tee -a $LOG_FILE_CORE
  exec ./run.sh
fi

for CD_DEVICE in $(ls /dev/sr*); do
  echo "[$(date +"%d-%m-%Y %H:%M:%S")] Found $CD_DEVICE" | tee -a $LOG_FILE_CORE
  gnome-terminal -x ./lib/cdcp.sh $CD_DEVICE
done

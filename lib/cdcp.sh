#! /bin/bash
# Wait for a CD to be inserted then copy the contents
#


store_dir_tmp=~/Documents
store_dir="$(dirname $store_dir_tmp)/$(basename $store_dir_tmp)"

LOG_DIR="log"

if [ -z "$1" ]; then
  echo "ERROR: No device name supplied"
  exit 1
fi

CD_DEVICE=$1
LOG_FILE="$LOG_DIR/cdcd_$(basename $CD_DEVICE).log"

if [ ! -d $store_dir ]; then
  echo "[$(date +"%d-%m-%Y %H:%M:%S")] ERROR: Store_dir not exist: $store_dir" | tee -a $LOG_FILE
#  mkdir -v -p $store_dir
  exit 1
else 
  echo "[$(date +"%d-%m-%Y %H:%M:%S")] store_dir: $store_dir" | tee -a $LOG_FILE
fi

echo "[$(date +"%d-%m-%Y %H:%M:%S")] CD copy, press <ctrl>C to exit" | tee -a $LOG_FILE
echo "[$(date +"%d-%m-%Y %H:%M:%S")] Looking for disk in $CD_DEVICE" | tee -a $LOG_FILE

while :
do
  TEST=$(grep $CD_DEVICE /proc/self/mounts)
  if [ "$TEST" == "" ]; then
    echo -ne "."
    sleep 1
  else
    echo
    DVD_NAME=$(blkid -o value -s LABEL $CD_DEVICE)
    NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
    set ${DVD_NAME// /_}
    set ${1,,}
    set "$(date +"%Y%m%d%H%M%S")-$(basename $CD_DEVICE)-$1-$NEW_UUID"
    DEST_FILE_NAME="$1.iso"
    echo "[$(date +"%d-%m-%Y %H:%M:%S")] Copying \"$DVD_NAME\" to $DEST_FILE_NAME" | tee -a $LOG_FILE
    date1=$(date +"%s")
    dd if=$CD_DEVICE of=$store_dir/$DEST_FILE_NAME 2>&1 | tee -a $LOG_FILE
    date2=$(date +"%s")
    diff=$(($date2-$date1))
    echo "[$(date +"%d-%m-%Y %H:%M:%S")] Finished in $(($diff / 60)) minutes and $(($diff % 60)) seconds. Calculating md5sum" | tee -a $LOG_FILE
    date1=$(date +"%s")
    md5sum $store_dir/$DEST_FILE_NAME > $store_dir/$DEST_FILE_NAME.md5sum
    date2=$(date +"%s")
    diff=$(($date2-$date1))
    echo "[$(date +"%d-%m-%Y %H:%M:%S")] $(cat $store_dir/$DEST_FILE_NAME.md5sum | awk '{print $1}') in $(($diff / 60)) minutes and $(($diff % 60)) seconds" | tee -a $LOG_FILE
    sleep 1
    eject $CD_DEVICE
    sleep 2
  fi
done
exit 0;

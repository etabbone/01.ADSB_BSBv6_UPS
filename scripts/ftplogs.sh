#!/bin/sh
echo "RPi project ADS-B / 01db acoem"
echo "FTPLOGS script"

HOST='192.168.0.1'
USER='01db'
PASSWD='____'

echo "gzip files"
day_list=`date --date="1 day ago" +"%Y%m%d*Flights.txt"`
day_logs=`date --date="1 day ago" +"%Y%m%d_LOGS_RPi.txt.gz"`

echo "Copying backup files from /mnt/usb/logs to /logs"
cp -u /mnt/usb/logs/$day_list /logs/.
sleep 2

cd /logs
gzip -c $day_list > $day_logs
cp $day_logs /mnt/usb/logs

echo "test DUO connexion"
ping -c12 $HOST

echo "Transfert file"
ftp -n $HOST <<END_SCRIPT
user $USER $PASSWD
binary
lcd /logs
cd /LOGS_RPi
put $day_logs
quit
END_SCRIPT
rm $day_list

exit 0


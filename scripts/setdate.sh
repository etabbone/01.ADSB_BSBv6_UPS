echo "Set date and time"
echo "Usage: setdate 20130920 08:55:49"
date +%Y%m%d -s $1
date +%T -s $2
exit 0


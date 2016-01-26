#!/bin/sh
echo "Delete files older than 180 days in /logs"
find /logs/* -mtime +180 -exec rm {} \;
exit 0

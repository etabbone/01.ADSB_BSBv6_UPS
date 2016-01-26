#!/bin/sh
echo "No blank screen"
sh -c "TERM=linux setterm -blank 0 >/dev/tty0"
exit 0


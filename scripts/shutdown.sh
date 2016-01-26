#!/bin/bash
# Power detection at UPiS PiCO interface with shutdown of Raspberry Pi after a definable time of power loss

# Set the shutdown delay after power loss to 30 seconds:
echo "UPiS Shutdown script"
DELAY=30

# Tmeout counter
COUNTER=0
# Endless loop
while true; do

  # Read power status
  POWERSTAT=`i2cget -y 1 0x6A 0`
  case "$POWERSTAT" in
    # The system is running on battery
    0x04)
      # if [ $COUNTER -eq 0 ]; then
      #		echo "`date` Power is lost!"
      # fi
      let COUNTER++
      # Wait 30s before shutdown
      if [ $COUNTER -gt $DELAY ]; then
	# echo "shutdonwn"
	pkill dump1090 --signal SIGUSR1
        shutdown -h now
        # STATE="shutdown"
        # logger -s  "`date` Exitting..."
        exit 0
      fi
      ;;
    # The system is not running on baterry
    *)
      # if [ $COUNTER -ne 0 ]; then
      # 	echo  "`date` Power is back"
      # fi
      COUNTER=0
      ;;
    esac
    sleep 1
done

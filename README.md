# 01.ADSB_BSBv6_UPS
**Raspberry Pi (RPi) embedded ADS-B decoding system with UPS linked to a professional Noise Monitoring Station**

**What is it?**

The Brasilia International Airport (BSB) need to know which fly is respecting the maximum noise level fixed by the Brazilian Government Health and Safety Regulation.

Basically, it’s an embedded system based on UPS and a Raspberry Pi (RPi) linked to a 01DB Duo/Cube Noise Monitoring Station. The software is based on a C++ modified version of the Linux DUMP1090 program https://github.com/MalcolmRobb/dump1090  (Dump1090 was written by Salvatore Sanfilippo antirez@gmail.com and is released under the BSD three clause license).

When the Duo Noise Station detect a high-level noise issued from a plane, it’s generate an alarm (TTL level output). The RPi system detect this alarm and save on the SD Card and Pen drive a file with all informations issued from the ADS-B decoder. 

To be an autonomous system, a solar panel will provide all the power needed, an UPS will start, and safety stop the RPi system. The start is delay (approximately 30min) to let the battery get a minimal charge. Alarm and stop signals are detected by the RPi using interrupt process. 

Some LEDs for displaying basics informations. A RTC chip provide a real date and time with backup and finally, the system is linked to the network to let access to all saved files.

![alt tag](https://github.com/etabbone/01.ADSB_BSBv6_UPS/blob/master/ADSB_UPS_Schema.jpg)

**Some features**

-	Powered by solar panel (and battery)
-	General start and stop system button
-	UPS with safety stop (close all file before stopping the RPi)
-	Power fail detection and automatic stop (after 15s)
-	Delayed start (30min)
-	Immediate RPi start button
-	File Safe power off button
-	Double backup (SD Card and Pen drive)
-	Alarm input signal optically isolated
-	Alarm signal and UPS signal detection based on interruption
-	RTC chip for Real Time (I2C)
-	Basic state LEDs display
-	Network connection
-	Wi-Fi is optional
-	Smalls dimensions (about 10x15cm)
-	During alarm signal, all informations about planes are saved on independent files (Fly code, GPS position, altitude, velocity…)

The new version of the DUMP1090 program read the BCM2835 serial number of the RPi and if needed, can compare for security reason this serial to the dump1090.bcm file in order to authorize (or not) the all process. 

*Read "<b>[RPi-adsb-v6](https://github.com/etabbone/01.ADSB_BSBv6_UPS/blob/master/RPi-adsb-v6.doc)</b>" for general information and "<b>[RPi-adsb-v6_Technical_Information](https://github.com/etabbone/01.ADSB_BSBv6_UPS/blob/master/RPi-adsb-v6_Technical_Information.doc)</b>" for technical information.*

**Hardware connections**

![alt tag](https://github.com/etabbone/01.ADSB_BSBv6_UPS/blob/master/ADSB_UPS_Tech.jpg)

Br load("Winky.autoconf#cp2fs.be")
Template {"NAME":"Winky","GPIO":[1,4704,1376,5632,4705,640,608,1,1,32,1,0,0,0,0,0,0,0,1,1,1,1],"FLAG":0,"BASE":1}
Module 0

; All these parameters are saved onto flash device
; so once configured, you can change them afterward
; in the file autoexec.be copied onto the filesystem
; =====================================================

; Disable Boot Loop Detection
SetOption65 1

; Set Telemetry to 10s (deepsleep)
TelePeriod 10

; # Set auto timezone
Backlog0 Timezone 99; TimeStd 0,0,10,1,3,60; TimeDst 0,0,3,1,2,120

; # Set Teleinfo in legacy (historique) mode at 1200 baud.
EnergyConfig Historique	

; # Enable sending of all frames in raw mode
EnergyConfig Full	

; # Send only each 1 on 10 frames received
EnergyConfig Skip 9

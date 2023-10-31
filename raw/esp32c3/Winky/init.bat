Br load("Winky.autoconf#cp2fs.be")
Template {"NAME":"Winky","GPIO":[1,4704,1376,5632,4705,640,608,1,1,32,1,0,0,0,0,0,0,0,1,1,1,1],"FLAG":0,"BASE":1}
Module 0

; All these parameters are saved onto flash device
; so once configured, it's better to leave them in
; file init.bat
; ===================================================

# Set auto timezone
;Backlog0 Timezone 99; TimeStd 0,0,10,1,3,60; TimeDst 0,0,3,1,2,120

# Don't display energy sensors on WebUI
;backlog0 WebSensor0 0 ; WebSensor1 0 ; WebSensor2 0 ; WebSensor3 0


; Set Teleinfo in legacy (historique) mode at 1200 baud.
EnergyConfig Historique	

; Set Teleinfo in standard mode at 9600 baud.
; EnergyConfig Standard	

; Enable sending of all frames in raw mode
EnergyConfig Full	

; Send only each 1 on 10 frames received
EnergyConfig Skip 9

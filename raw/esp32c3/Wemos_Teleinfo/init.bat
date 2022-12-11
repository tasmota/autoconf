Template {"NAME":"Wemos Teleinfo","GPIO":[1,1,1376,1,5632,1,1,288,640,1,608,1,1,1,1376,1,1,640,1,0,1,1],"FLAG":0,"BASE":1}
Module 0

; All these parameters are saved onto flash device
; so once configured, it's better to leave them in
; file init.bat
; ===================================================

; Set Teleinfo in legacy (historique) mode at 1200 baud.
EnergyConfig Historique	

; Set Teleinfo in standard mode at 9600 baud.
; EnergyConfig Standard	

; Enable sending of all frames in raw mode
EnergyConfig Full	

; Send only each 1 on 10 frames received
EnergyConfig Skip 9

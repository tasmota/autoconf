Template {"NAME":"Denky D4 (v1.1)","GPIO":[32,0,0,0,1,0,0,0,0,1,1376,1,0,0,0,0,0,640,608,0,0,0,0,0,0,0,5632,0,0,0,0,0,0,0,0,0],"FLAG":0,"BASE":1}
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



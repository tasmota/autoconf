Template {"NAME":"Wemos Teleinfo","GPIO":[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1376,1,1,640,608,5632,1,1,0,1,0,0,0,1,1,1,1,1,1,1,1,1],"FLAG":0,"BASE":1}
Module 0

; All these parameters are saved onto flash device
; only once when autoconf is activated or 
; when it's removed and activated again
; ===================================================

; Disable Boot Loop Detection
SetOption65 1

; define OTA Url
OtaUrl https://github.com/NicolasBernaerts/tasmota/raw/master/teleinfo/binary/tasmota32-teleinfo.bin

; # Set auto timezone
Backlog0 Timezone 99; TimeStd 0,0,10,1,3,60; TimeDst 0,0,3,1,2,120

; # Set Teleinfo in legacy (historique) mode at 1200 baud.
; EnergyConfig Historique	

; # Set Teleinfo in stadard mode at 9600 baud.
; EnergyConfig Standard



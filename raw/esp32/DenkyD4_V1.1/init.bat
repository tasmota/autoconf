Br load("DenkyD4_V1.1.autoconf#cp2fs.be")
Template {"NAME":"Denky D4 (v1.1)","GPIO":[32,0,0,0,1,0,0,0,0,1,1376,1,0,0,0,0,0,640,608,0,0,0,0,0,0,0,5632,0,0,0,0,0,0,0,0,0],"FLAG":0,"BASE":1}
Module 0

; All these parameters are saved onto flash device
; only once when autoconf is activated or 
; when it's removed and activated again
; ===================================================

; Disable Boot Loop Detection
SetOption65 1

; define OTA Url
OtaUrl https://github.com/NicolasBernaerts/tasmota/raw/master/teleinfo/binary/tasmota32-teleinfo-denkyd4.bin

; Set auto timezone
Backlog0 Timezone 99; TimeStd 0,0,10,1,3,60; TimeDst 0,0,3,1,2,120

; Set Teleinfo in legacy (historique) mode at 1200 baud.
; EnergyConfig Historique	

; Set Teleinfo in standard mode at 9600 baud.
; EnergyConfig Standard

; Set LED brightness to 75%, in sleep mode it will be bright/2
Energyconfig bright=75

; 0 for Green LED and 1 for Period Indicator (blue, white or red)
Energyconfig period=1 

; Set Teleinfo to autodetect mode (standard or historique)
; this one restart device, use it at the end of file
Energyconfig automode 

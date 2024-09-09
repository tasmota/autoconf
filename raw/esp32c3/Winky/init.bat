Br load("Winky.autoconf#cp2fs.be")
Template {"NAME":"Winky C3","GPIO":[1,4704,1376,5632,4705,640,608,1,1,32,1,0,0,0,0,0,0,0,1,1,1,1],"FLAG":0,"BASE":1}
Module 0

; All these parameters are saved onto flash device
; so once configured, you can change them afterward
; in the file autoexec.be copied onto the filesystem
; =====================================================

; Disable Boot Loop Detection
SetOption65 1

; Enable Wifi Scan (avoid wifi lost if router change channel)
SetOption56 1

; Set Telemetry to 290s (300 special reserved by tasmota)
TelePeriod 290

; Set Sleeping time
DeepSleepTime 290

; define OTA Url
OtaUrl https://github.com/NicolasBernaerts/tasmota/raw/master/teleinfo/binary/tasmota32c3-teleinfo-winky.bin

; Set auto timezone
Backlog0 Timezone 99; TimeStd 0,0,10,1,3,60; TimeDst 0,0,3,1,2,120

; Set Teleinfo in legacy (historique) mode at 1200 baud.
; EnergyConfig Historique	

; Set Teleinfo in stadard mode at 9600 baud.
; EnergyConfig Standard

; Set Teleinfo to autodetect mode (standard or historique)
Energyconfig automode 

; Set LED brightness to 75%, in sleep mode it will be bright/2
Energyconfig bright=75

; 0 for Green LED and 1 for Period Indicator (blue, white or red)
Energyconfig period=1 


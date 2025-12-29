Template {"NAME":"EthTinfo (Olimex ESP32)","GPIO":[1,1,8864,1,0,1376,0,0,5536,1,8832,8800,0,0,5600,1,1,1,1,5568,1,1,1,1,0,0,0,0,1,1,32,1,5632,1,1,1],"FLAG":0,"BASE":1}
Module 0
EthType 0
EthAddress 0
EthClockMode 3


; All these parameters are saved onto flash device
; so once configured, you can change them afterward
; in the file autoexec.be copied onto the filesystem
; =====================================================

; Disable Boot Loop Detection
SetOption65 1

; define OTA Url
OtaUrl https://github.com/NicolasBernaerts/tasmota/raw/master/teleinfo/binary/tasmota32-teleinfo-ethernet.bin

; Set auto timezone
Backlog0 Timezone 99; TimeStd 0,0,10,1,3,60; TimeDst 0,0,3,1,2,120

; Set Teleinfo in legacy (historique) mode at 1200 baud.
; EnergyConfig Historique	

; Set Teleinfo in standard mode at 9600 baud.
; EnergyConfig Standard

; Set Teleinfo to autodetect mode (standard or historique)
; old firmware commnand, deprecated
; Energyconfig automode 

; Set Teleinfo to autodetect mode 
Energyconfig reset 


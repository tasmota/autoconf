Template {"NAME":"EthTinfo (Olimex ESP32)","GPIO":[1,1,8864,1,0,1,0,0,5536,1,8832,8800,0,0,5600,1,1,1,1,5568,1,1,1,1,0,0,0,0,1,1,32,1,5632,1,1,1],"FLAG":0,"BASE":1}
Module 0
EthType 0
EthAddress 0
EthClockMode 3

OtaUrl https://raw.githubusercontent.com/tasmota/install/main/firmware/unofficial/tasmota32-teleinfo.bin

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

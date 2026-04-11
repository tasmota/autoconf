; Generic Teleinfo
; ----------------

; Reset settings, but preserve wifi, MQTT and FS
InitDevice 6

; Disable analog values display
WebSensor2 0

; Disable energy values display
WebSensor3 0

; Disable Boot Loop Detection
SetOption65 1

; Enable Wifi Scan (avoid wifi lost if router change channel)
SetOption56 1

; Set Telemetry to 290s (300 special reserved by tasmota)
TelePeriod 290

; Set WebRefresh to 1 second
WebRefresh 1000

; Set auto timezone
Backlog Timezone 99; TimeStd 0,0,10,1,3,60; TimeDst 0,0,3,1,2,120;

; Set blinking LED color : 0 for Green LED and 1 for Period Indicator (blue, white or red)
; Set Teleinfo to autodetect mode 
Energyconfig period=1 reset

; Winky C6
; --------

; copy some samples to FS
Br load("Winky.autoconf#cp2fs.be")

; Set module configuration
Template {"NAME":"Winky","GPIO":[1,4704,1376,4705,5632,4706,640,608,1,32,1,0,0,0,0,0,0,0,1,1,1,1,3840,4096,0,0,0,0,0,0,0],"FLAG":0,"BASE":1}

; OTA Url
OtaUrl https://github.com/NicolasBernaerts/tasmota/raw/master/teleinfo/binary/tasmota32c6-teleinfo-winky.bin

; Set LED brightness to 75%, in sleep mode it will be bright/2
Energyconfig bright=75

; Set DeepSleep time based on tension
winky_sleep 0

; Set Sleep to 100ms to unload CPU
Sleep 100

; Set default module
Module 0



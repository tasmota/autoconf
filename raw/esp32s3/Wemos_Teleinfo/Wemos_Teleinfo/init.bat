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

; Set WebRefresh to 1 second
WebRefresh 1000

; Set auto timezone
Backlog Timezone 99; TimeStd 0,0,10,1,3,60; TimeDst 0,0,3,1,2,120;

; Set blinking LED color : 0 for Green LED and 1 for Period Indicator (blue, white or red)
; Set Teleinfo to autodetect mode 
Energyconfig period=1 reset

; Wemos S3 Teleinfo
; -----------------

; Set module configuration
Template {"NAME":"Wemos S3 Teleinfo","GPIO":[32,1,1,0,0,1,1,1,1,1,1,5632,1376,1,0,1,1,1,1,1,1,1,0,0,640,608,0,0,0,0,0,0,1,1,0,0,1377,0],"FLAG":0,"BASE":1}

; Set LED brightness to 75%, in sleep mode it will be bright/2
Energyconfig bright=75

; OTA Url
OtaUrl https://github.com/NicolasBernaerts/tasmota/raw/master/teleinfo/binary/tasmota32s3-teleinfo.bin

; Set serial log output to info
SerialLog 2

; Set default module
Module 0


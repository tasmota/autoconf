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

; EthTinfo
; --------

; Set module configuration
Template {"NAME":"EthTinfo (Olimex ESP32)","GPIO":[1,1,8864,1,0,1376,0,0,5536,1,8832,8800,0,0,5600,1,1,1,1,5568,1,1,1,1,0,0,0,0,1,1,32,1,5632,1,1,1],"FLAG":0,"BASE":1}
Module 0
EthType 0
EthAddress 0
EthClockMode 3

; Set LED brightness to 75%, in sleep mode it will be bright/2
Energyconfig bright=75

; OTA Url
OtaUrl https://github.com/NicolasBernaerts/tasmota/raw/master/teleinfo/binary/tasmota32-teleinfo-ethernet.bin

; Set serial log output to info on uart0 (log to onboard USB/Serial)
Backlog SerialConfig 8N1; Baudrate 115200; SerialLog 2;

; Set default module
Module 0



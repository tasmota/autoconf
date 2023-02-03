Template {"NAME":"Olimex ESP32-PoE-BioPDU","GPIO":[1,10209,10210,1,10144,1,0,0,5536,640,1,1,608,0,5600,0,0,0,0,5568,0,0,0,0,0,0,0,0,1,10208,1,1,10176,0,0,1],"FLAG":0,"BASE":1}  
Module 0

; Ethernet Configuration
EthType 0
EthAddress 0
EthClockMode 3

; Use indexes even when only one relay is present
;   0 = messages use POWER (default)
;   1 = messages use POWER1
SetOption26 1

; Enable split total energy results #13030
SetOption129 1

; Force no voltage/frequency common
SetOption150 1

; Rotate if over EnergyCols
EnergyDisplay 1

; 6 Number of GUI data columns
EnergyCols 6

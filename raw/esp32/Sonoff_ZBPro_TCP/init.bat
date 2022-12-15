Template {"NAME":"TCP ZBBridge Pro","GPIO":[0,0,576,0,480,0,0,0,0,1,1,5792,0,0,0,5472,0,320,5793,5504,0,640,608,32,0,0,0,0,0,1,0,0,0,0,0,0],"FLAG":0,"BASE":1}
Module 0
OtaUrl https://ota.tasmota.com/tasmota32/tasmota32-zbbrdgpro.bin
rule on system#boot do TCPStart 8888 endon
rule 1
TCPStart 8888

Template {"NAME":"ODROID_GO_I2C","GPIO":[32,3200,544,3232,608,768,0,0,6210,33,416,640,1,1,736,672,0,800,6720,704,0,0,0,34,0,0,0,0,164,165,3328,3329,4866,0,0,35],"FLAG":0,"BASE":3}
Module 0
adcparam3 6,0,4095,0,6160
rule on analog#joy2=1 do dimmer - endon on analog#joy2=2 do dimmer + endon
rule 1

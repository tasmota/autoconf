; Configure I2C Sensor29 (MCP23008)
;
;   pin 0   {"Sensor29_D0":{"MODE":1,"PULL_UP":"OFF","INT_MODE":"DISABLED","STATE":"OFF"}}
;   pin 1   {"Sensor29_D1":{"MODE":5,"START_UP":"SAVED","STATE":"OFF"}}
;   pin 2   {"Sensor29_D2":{"MODE":5,"START_UP":"SAVED","STATE":"OFF"}}   
;   pin 3   {"Sensor29_D3":{"MODE":5,"START_UP":"SAVED","STATE":"OFF"}}
;   pin 4   {"Sensor29_D4":{"MODE":5,"START_UP":"SAVED","STATE":"OFF"}}
;   pin 5   {"Sensor29_D5":{"MODE":5,"START_UP":"SAVED","STATE":"OFF"}}
;   pin 6   {"Sensor29_D6":{"MODE":5,"START_UP":"SAVED","STATE":"OFF"}}
;   pin 7   {"Sensor29_D7":{"MODE":1,"PULL_UP":"OFF","INT_MODE":"DISABLED","STATE":"OFF"}}
;
BackLog0 i2cscan;Sensor29 0,1,0;Sensor29 1,5,2;Sensor29 2,5,2;Sensor29 3,5,2;Sensor29 4,5,2;Sensor29 5,5,2;Sensor29 6,5,2;Sensor29 7,1,0

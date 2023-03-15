Template {"NAME":"Shelly Pro 4PM","GPIO":[0,6210,0,6214,9568,0,0,0,0,0,9569,0,10272,0,5600,0,0,0,0,5568,0,0,0,0,0,0,0,0,736,704,3461,10240,4736,0,0,672],"FLAG":0,"BASE":1}
Module 0
AdcParam1 2,5600,4700,3350

; copy display.ini and mcp23x.dat in file-system
br def extract(fname) try var f = open(autoconf._archive + "#" + fname) var content = f.read() f.close() var f2 = open(fname, 'w') f2.write(content) f2.close() except "io_error" as e,m tasmota.log("BRY: failed to extract: " + fname + ", " + m, 2) end end
br extract("display.ini")
br extract("mcp23x.dat")


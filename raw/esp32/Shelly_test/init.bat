; copy display.ini and mcp23x.dat in file-system
br def extract(fname) try var f = open(tasmota.wd + fname) var content = f.read() f.close() var f2 = open(fname, 'w') f2.write(content) f2.close() except "io_error" as e,m tasmota.log("BRY: failed to extract: " + fname + ", " + m, 2) end end
br extract("display.ini")
br extract("mcp23x.dat")


import path

# make sure bootloader.bin is in the file-system
if !path.exists("bootloader.bin")
  try
    var f_in = open(tasmota.wd + "bootloader.bin")
    var f_content = f_in.readbytes()
    f_in.close()
    var f_out = open("bootloader.bin", "w")
    f_out.write(f_content)
    f_out.close()
  except .. as e,m
    print("> Couldn't copy bootloader.bin",e,m)
  end
end

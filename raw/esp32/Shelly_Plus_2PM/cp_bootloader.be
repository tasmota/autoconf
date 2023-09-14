import path

path.remove("index.html.gz")
path.remove("tzinfo")


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

# make sure Partition_Wizard.tapp is in the file-system
if !path.exists("Partition_Wizard.tapp")
  try
    var f_in = open(tasmota.wd + "Partition_Wizard.tapp")
    var f_content = f_in.readbytes()
    f_in.close()
    var f_out = open("Partition_Wizard.tapp", "w")
    f_out.write(f_content)
    f_out.close()
  except .. as e,m
    print("> Couldn't copy Partition_Wizard.tapp",e,m)
  end
end

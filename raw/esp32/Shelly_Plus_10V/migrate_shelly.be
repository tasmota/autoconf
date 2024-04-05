# migration script for Shelly

# simple function to copy from autoconfig archive to filesystem
# return true if ok
def cp(from, to)
  import path
  if to == nil    to = from   end     # to is optional
  if !path.exists(to)
    try
      # tasmota.log("f_in="+tasmota.wd + from)
      var f_in = open(tasmota.wd + from)
      var f_out = open(to, "w")
      var f_content = f_in.readbytes(0x2000)  # read by chunks of 8kb
      while size(f_content) > 0
        f_out.write(f_content)
        f_content = f_in.readbytes(0x2000)    # read next chunk
      end
      f_in.close()
      f_out.close()
    except .. as e,m
      tasmota.log("OTA: Couldn't copy "+to+" "+e+" "+m,2)
      return false
    end
    return true
  end
  return true
end

def copy_ota(from_addr, to_addr, sz)
  import flash
  import string
  var size_left = sz
  var offset = 0

  tasmota.log(string.format("UPL: Copy flash from 0x%06X to 0x%06X (size: %ikB)", from_addr, to_addr, sz / 1024), 2)
  while size_left > 0
    var b = flash.read(from_addr + offset, 4096)
    flash.erase(to_addr + offset, 4096)
    flash.write(to_addr + offset, b, true)
    size_left -= 4096
    offset += 4096
    if ((offset-4096) / 102400) < (offset / 102400)
      tasmota.log(string.format("UPL: Progress %ikB", offset/1024), 3)
    end
  end
  tasmota.log("UPL: done", 2)
end

# make some room if there are some leftovers from shelly
import path
path.remove("index.html.gz")

# copy some files from autoconf to filesystem
var ok
ok = cp("bootloader-tasmota-32.bin")
ok = cp("Partition_Wizard.tapp")

# use an alternative to partition_core that can read Shelly's otadata
tasmota.log("OTA: loading "+tasmota.wd + "partition_core_shelly.be", 2)
load(tasmota.wd + "partition_core_shelly.be")

# load bootloader flasher
tasmota.log("OTA: loading "+tasmota.wd + "bootloader.be", 2)
load(tasmota.wd + "bootloader.be")


# all good
if ok
  # do some basic check that the bootloader is not already in place
  import flash
  if flash.read(0x2000, 4) == bytes('0030B320')
    tasmota.log("OTA: bootloader already in place, not flashing it")
  else
    ok = global.bootloader().flash("bootloader-tasmota-32.bin")
  end
  if ok
    var p = global.partition_core_shelly.Partition()
    var app0 = p.get_ota_slot(0)
    var app1 = p.get_ota_slot(1)
    var app0_size = app0.get_image_size()
    var app1_size = app1.get_image_size()
    # check if we get some Tasmota signature in slot 1
    if (flash.read(p.get_ota_slot(1).start + 16, 4) == bytes("00FFFF00"))
      copy_ota(app1.start, app0.start, app1_size)
    elif (flash.read(p.get_ota_slot(0).start + 16, 4) == bytes("00FFFF00"))
      copy_ota(app0.start, app1.start, app0_size)
    end
    var otadata_offset = p.otadata.offset
    flash.erase(otadata_offset, 0x2000)
    tasmota.log("OTA: Shelly migration successful", 2)
  end
end

# dump logs to file
var lr = tasmota_log_reader()
var f_logs = open("migration_logs.txt", "w")
var logs = lr.get_log(2)
while logs != nil
  f_logs.write(logs)
  logs = lr.get_log(2)
end
f_logs.close()

# Done

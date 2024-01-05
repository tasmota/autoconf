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
    p.save()      # save with otadata compatible with new bootloader
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

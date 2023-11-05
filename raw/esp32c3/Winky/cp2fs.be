# Copy teleinfo driver to file system to be end user editable

# simple function to copy from autoconfig archive to filesystem
# return true if ok
def cp(from, to)
  import path
  if to == nil    to = from   end     # to is optional
  tasmota.log("OTA: copying "+tasmota.wd + to, 2)
  if !path.exists(to)
    try
      # tasmota.log("f_in="+tasmota.wd + from)
      var f_in = open(tasmota.wd + from)
      var f_content = f_in.readbytes()
      f_in.close()
      var f_out = open(to, "w")
      f_out.write(f_content)
      f_out.close()
    except .. as e,m
      tasmota.log("OTA: Couldn't copy "+to+" "+e+" "+m,2)
      return false
    end
    return true
  end
  return true
end

import path

# copy some samples files from autoconf 
# to filesystem for end user speed up learn
cp("_autoexec.be", "autoexec.be")
cp("_teleinfo.be", "teleinfo.be")

# Done

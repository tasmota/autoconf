# load HASPmota using pages.jsonl
import haspmota
import path

#tasmota.wd = "01Space_ESP32-C3-0.42LCD.autoconf#"
# make sure m5x7.lvfont is in the file-system
if !path.exists("m5x7.lvfont")
  try
    var f_in = open(tasmota.wd + "m5x7.lvfont")
    var f_content = f_in.readbytes()
    f_in.close()
    var f_out = open("m5x7.lvfont", "w")
    f_out.write(f_content)
    f_out.close()
  except .. as e,m
    print("> Couldn't copy m5x7.lvfont",e,m)
  end
end

# check if `pages.jsonl` exists in file-system
if path.exists("pages.jsonl")
  haspmota.start(false)
else  # or use the template inside the autoconf file
  haspmota.start(false, tasmota.wd + "pages.jsonl")
end

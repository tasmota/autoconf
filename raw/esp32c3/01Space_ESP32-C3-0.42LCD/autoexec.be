# load HASPmota using pages.jsonl
import haspmota
import path

# check if `pages.jsonl` exists in file-system
if path.exists("pages.jsonl")
  haspmota.start(false)
else  # or use the template inside the autoconf file
  haspmota.start(false, tasmota.wd + "pages.jsonl")
end

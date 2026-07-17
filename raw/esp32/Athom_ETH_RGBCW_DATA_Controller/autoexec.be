# Disable Wifi when Eth is up to reduce radio interference
# from https://tasmota.github.io/docs/Berry-Cookbook/#ethernet-network-flipper

def netflip()
  var eth = tasmota.eth('up')                 #1
  if tasmota.wifi('up') == eth                #2
    tasmota.cmd('Wifi ' + (eth ? '0' : '1'))  #3
  end
  tasmota.set_timer(30000,netflip)            #4
end
tasmota.set_timer(30000,netflip)              #5


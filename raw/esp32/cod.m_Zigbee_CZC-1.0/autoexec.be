# Ethernet Network Flipper - checks every 30 seconds if ethernet if up
# if Ethernet is up, Wifi is turned off to avoid interference with Zigbee
# if Ethernet is down, Wifi is turned back on to allow fallback connection
def netflip()
  var eth = tasmota.eth('up')                 #1
  if tasmota.wifi('up') == eth                #2
    tasmota.cmd('Wifi ' + (eth ? '0' : '1'))  #3
  end
  tasmota.set_timer(30000,netflip)            #4
end
tasmota.set_timer(30000,netflip)              #5


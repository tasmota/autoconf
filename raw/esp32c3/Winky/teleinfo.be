# Winky Teleinfo Driver, this is just a sample file that read both
# voltage (USB and Super Capacitor), display on Web UI
# and add them to telemetry sent values

class TELEINFO: Driver

  var vusb
  var vcap

  def init()
    # initialize globals
	self.vusb = 0
  	self.vcap = 0

    # create rules to trigger when Analog values updates 
    tasmota.add_rule("ANALOG#A1", /value -> self.trigger_a1(value))
    tasmota.add_rule("ANALOG#A2", /value -> self.trigger_a2(value))
  end

  def trigger_a1(v) 
    v = int(v)
    # Voltage is divided by 2 by a resistor R/R divider
  	self.vusb = 3.3 * 2.0 * v / 4095
  end

  def trigger_a2(v) 
    v = int(v)
    # Voltage is divided by 2 by a resistor R/R divider
  	self.vcap = 3.3 * 2.0 * v / 4095
  end
  
  #- trigger a read every second -#
  def every_second()
    # DEBUG print("sensors:",tasmota.read_sensors())
  end

  #- display sensor value in the web UI -#
  def web_sensor()
    import string
    var msg = string.format(
            "{s}USB{m}%.1f V{e}"
            "{s}Super Capacitor{m}%.1f V{e}",
             self.vusb, self.vcap )

    tasmota.web_send_decimal(msg)
  end


  #- add sensor value to teleperiod -#
  def json_append()
    import string
    var Msg = string.format(',"vsub":%.1f, "vcap":%.1f }', self.vusb, self.vcap)

    tasmota.response_append(Msg)
  end

end

teleinfo = TELEINFO()
tasmota.add_driver(teleinfo)

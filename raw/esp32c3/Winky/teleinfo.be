# Winky Teleinfo Driver, this is just a sample file that read both
# voltage (USB and Super Capacitor), display on Web UI

class TELEINFO: Driver
  var vusb
  var vcap
  var strip
  var bri
  var is_usb
  var deepsleep

  def init()
    import json
    # First we need to get Analog voltage 
    var sensors=json.load(tasmota.read_sensors())
    self.on_a1(sensors['ANALOG']['A1'] )
    self.on_a2(sensors['ANALOG']['A2'] )

    # Get current value of deepsleep
    var ds = tasmota.cmd("DeepSleepTime")
    self.deepsleep = ds['DeepSleepTime']

    # Get LED Brightness from UI
    var led = light.get()
    self.bri = led["bri"]

    # Instantiate our 2 WS2812 Leds
    self.strip = Leds(2, 2, gpio.pin(gpio.WS2812, 1))

    # Check Super Capacitor Voltage
    if self.vcap < 4.5
      # Not enough we should go to deepsleep from here
      self.strip.set_pixel_color(0, 0xFF0000, self.bri)
      self.sleep()
    else
      self.strip.set_pixel_color(0, 0x00FF00, self.bri)
    end
    self.strip.show()

    # create rules to trigger
    tasmota.add_rule("System#Init", /value -> self.set_led(0xFFFF00))
    tasmota.add_rule("Wifi#Connected", /value -> self.set_led(0x00FFFF))
    tasmota.add_rule("Mqtt#Connected", /value -> self.set_led(0x00FF00))

    tasmota.add_rule("ANALOG#A1", /value -> self.on_a1(value) )
    tasmota.add_rule("ANALOG#A2", /value -> self.on_a2(value) )
    tasmota.add_rule("Tele#Energy#Power", /value -> self.done(value) )

  end

  def analog2voltage(v) 
    v = int(v)
    # Voltage is divided by 2 by a resistor R/R divider
    return 3.3 * 2.0 * v / 4095
  end

  def set_deepsleep(s)
    # avoid same write il value is eq
    if self.deepsleep != s
      self.deepsleep = s
      var cmd = "deepsleeptime " + str(s)
      print(cmd)
      tasmota.cmd(cmd)
    end
  end

  def sleep() 
    var ds = 0
    if self.is_usb == false
      # DEBUG 
      print("All Done, going to sleep")
      self.strip.set_pixel_color(1, 0x000000, self.bri)
      self.strip.set_pixel_color(0, 0x000000, self.bri)
      self.strip.show()
      if gpio.digital_read(8) != 0
        # Sleep for 1 min
        ds = 60 
      else
        print("Button prevented sleep")
      end
    else
      print("USB Connected no sleep")
    end
    self.set_deepsleep(ds)
  end

  def done(value) 
    self.strip.set_pixel_color(1, 0x000000, self.bri)
    self.strip.set_pixel_color(0, 0x00FF00, self.bri)
    self.strip.show()
    tasmota.set_timer(500, /value -> self.sleep())
  end

  def set_led(color) 
    # DEBUG print("Color:", color, "BRI:", self.bri)
    self.strip.set_pixel_color(1, color, self.bri)
    self.strip.show()
  end

  def on_a1(value) 
    self.vusb = self.analog2voltage(value)
    if self.vusb > 4.5
      self.is_usb = true 
      # Remove deepsleep
      self.set_deepsleep(0)
    else
      self.is_usb = false
    end
  end

  def on_a2(value) 
    import string
    self.vcap = self.analog2voltage(value)
    # DEBUG 
    print(string.format("SuperCap:%.2fV  USB:%.2fV  USB:%d", self.vcap, self.vusb, self.is_usb))
  end
  
  def every_second()
    # DEBUG print("sensors:",tasmota.read_sensors())
  end

  # display sensor value in the web UI 
  def web_sensor()
    import string
    var msg = string.format(
            "{s}USB{m}%.1f V{e}"
            "{s}Super Capacitor{m}%.1f V{e}",
             self.vusb, self.vcap )

    tasmota.web_send_decimal(msg)
  end


  #- add sensor value to teleperiod -#
  # Looks like this one prevents "Tele#Sensor#......" 
  # to be triggered so leave it as comment for now
#  def json_append()
#    import string
#    var Msg = string.format(',"vsub":%.1f, "vcap":%.1f }', self.vusb, self.vcap)
#    tasmota.response_append(Msg)
#    self.trigger_done()
#  end

end

teleinfo = TELEINFO()
tasmota.add_driver(teleinfo)


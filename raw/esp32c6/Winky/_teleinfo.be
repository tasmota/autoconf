# Winky Teleinfo Driver, this is just a sample file that read both
# voltage (USB and Super Capacitor), display on Web UI

class TELEINFO: Driver
  var vusb
  var vcap
  var vlky
  var strip
  var bri
  var is_usb
  var tick_500ms

  def init()
    # First we need to get Analog voltage 
    self.tick_500ms = false
    self.every_500ms()

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
    tasmota.add_rule("Tele#Energy#Power", /value -> self.done(value) )

  end

  def analog2voltage(v) 
    v = int(v)
    return 3.3 * v / 4095
  end

  def set_deepsleep(s)
    var cmd = "deepsleeptime " + str(s)
    print ("set_deepsleep() ", cmd)
    tasmota.cmd(cmd)
  end

  def sleep() 
    self.strip.set_pixel_color(1, 0x000000, self.bri)
    self.strip.set_pixel_color(0, 0x000000, self.bri)
    self.strip.show()
    print ("sleep()")
    if self.is_usb == false
      # DEBUG 
      print("All Done, going to sleep")
      if gpio.digital_read(23) != 0
        # Sleep for 15s
        self.set_deepsleep(15)
      else
        print("Button prevented sleep")
      end
    else
      print("USB Connected no sleep")
    end
  end

  def done(value) 
    print("Done")
    self.strip.set_pixel_color(1, 0x000000, self.bri)
    self.strip.set_pixel_color(0, 0xFF00FF, self.bri)
    self.strip.show()
    tasmota.set_timer(250, /value -> self.sleep())
  end

  def set_led(color) 
    # DEBUG print("Color:", color, "BRI:", self.bri)
    self.strip.set_pixel_color(1, color, self.bri)
    self.strip.show()
  end

  def every_500ms()
    import json
    import string
    # using in one line at boot fired error on nil value
    # splitted in 2 lines read and load resolved the issue
    # var sensors=json.load(tasmota.read_sensors())
    var sensors=tasmota.read_sensors()
    sensors=json.load(sensors)
    # Voltage is divided by 2 by a resistor R/R divider
    self.vcap = self.analog2voltage(sensors['ANALOG']['A2']) * 2
    self.vusb = self.analog2voltage(sensors['ANALOG']['A1']) * 2
    # Voltage is divided by 5.7 by a resistor R/R divider
    self.vlky = self.analog2voltage(sensors['ANALOG']['A3']) * 5.7
    if self.vusb > 4.5
      self.is_usb = true 
    else
      self.is_usb = false
    end
    # DEBUG 
    print(string.format("Linky:%.2fV  SCap:%.2fV  USB:%.2fV  USB:%d", self.vlky, self.vcap, self.vusb, self.is_usb))
  end

  def every_250ms()
    if self.tick_500ms == true
      self.tick_500ms = false
      self.every_500ms()
    else
      self.tick_500ms = true
    end
  end
  
  def every_second()
    # DEBUG print("sensors:",tasmota.read_sensors())
  end

  # display sensor value in the web UI 
  def web_sensor()
    import string
    var msg = string.format(
            "{s}Linky{m}%.2f V{e}"
            "{s}USB{m}%.2f V{e}"
            "{s}Super Capacitor{m}%.2f V{e}",
             self.vlky, self.vusb, self.vcap )

    tasmota.web_send_decimal(msg)
  end


  #- add sensor value to teleperiod -#
  # Looks like this one prevents "Tele#Sensor#......" 
  # to be triggered so leave it as comment for now
  def json_append()
    if !self.vusb return nil end 
    if !self.vcap return nil end 
    if !self.vlky return nil end 
    import string
    var msg = string.format(',"vsub":%i, "vcap":%i }', int(self.vusb*1000), int(self.vcap*1000))
#    print(msg)
#    tasmota.response_append(msg)
  end

end

teleinfo = TELEINFO()
tasmota.add_driver(teleinfo)


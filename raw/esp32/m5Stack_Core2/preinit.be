#-
 - Example of I2C driver written in Berry
 -
 -#

class I2C_Driver : Driver
  var wire          #- if wire == nil then the module is not initialized -#
  var addr
  var name

  def init(addr, name)
    import string
    var tasmota = self.get_tasmota()

    self.addr = addr                            #- address for AXP192 -#
    self.wire = tasmota.wire_scan(self.addr)    #- get the right I2C bus -#
    self.name = name                            #- display name for I2C device -#

    if self.wire
      print(string.format("I2C: %s detected on bus %d", self.name, self.wire.bus))
    end
  end

  def log_write1(reg, val)
    import string
    var tasmota = self.get_tasmota()
    tasmota.log(string.format("I2C: (0x%02X) write %02X:%02X", self.addr, reg, val))
  end

  def write1(reg, val)
    self.log_write1(reg, val)
    return self.wire.write(self.addr, reg, val, 1)
  end

  # Set or clear a specific bit in a register
  def write_bit(reg, bit, state)
    if bit < 0 || bit > 7 return end
    var mark = 1 << bit
    if state    self.write1(reg, self.read8(reg) | mark)
    else        self.write1(reg, self.read8(reg) & (0xFF - mark))
    end
  end

  def read8(reg)
    return self.wire.read(self.addr, reg, 1)
  end
  def read12(reg)
    var buf = self.wire.read_bytes(self.addr, reg, 2)
    return (buf[0] << 4) + buf[1]
  end
  def read13(reg)
    var buf = self.wire.read_bytes(self.addr, reg, 2)
    return (buf[0] << 5) + buf[1]
  end
  def read24(reg)
    var buf = self.wire.read_bytes(self.addr, reg, 3)
    return (buf[0] << 16) + (buf[1] << 8) + buf[2]
  end
end

######################################################################
#-
 -
 -#
######################################################################
class AXP192 : I2C_Driver
  def init()
    super(self).init(0x34, "AXP192")
  end

  # Return True = Battery Exist
  def battery_present()
    if self.wire.read(self.addr, 0x01, 1) & 0x20 return true
    else return false
    end
  end

  # Input Power Status ???
  def get_input_power_status()
    return self.wire.read(self.addr, 0x00, 1)
  end

  # Battery Charging Status
  def get_battery_chargin_status()
    return self.wire.read(self.addr, 0x01, 1)
  end

  def get_temp()
    return self.read12(0x5E) * 0.1 - 144.7
  end

  def get_bat_power()
    return self.read24(0x70) * 0.00055
  end

  def get_bat_voltage()
    return self.read12(0x78) * 0.0011
  end
  def get_bat_current()
    return (self.read13(0x7A) - self.read13(0x7C)) * 0.5
  end
  def get_bat_charge_current()
    return self.read13(0x7A) * 0.5
  end
  def get_aps_voltage()
    return self.read12(0x7E) * 0.0014
  end
  def get_vbus_voltage()
    return self.read12(0x5A) * 0.0017
  end
  def get_vbus_current()
    return self.read12(0x5C) * 0.375
  end

  # set LDO voltage
  def set_ldo_voltage(ldo, voltage)
    if   voltage > 3300   voltage = 15
    else voltage = (voltage / 100) - 18
    end

    if ldo == 2
      self.write1(0x28, self.read8(0x28) & 0x0F | ((voltage & 0x0F) << 4))
    end
    if ldo == 3
      self.write1(0x28, self.read8(0x28) & 0xF0 | (voltage & 0x0F))
    end
  end

  # set DCDC enable, 1/2/3
  def set_dcdc_enable(dcdc, state)
    if dcdc == 1  self.write_bit(0x12, 0, state) end
    if dcdc == 2  self.write_bit(0x12, 4, state) end
    if dcdc == 3  self.write_bit(0x12, 1, state) end
  end

  # set LDO enable, 2/3 (LDO 1 is always on)
  def set_ldo_enable(ldo, state)
    if ldo == 2   self.write_bit(0x12, 2, state) end
    if ldo == 3   self.write_bit(0x12, 3, state) end
  end

  # set GPIO output state 0/1/2 and 3/4
  def write_gpio(gpio, state)
    if   gpio >= 0 && gpio <= 2
      self.write_bit(0x94, gpio, state)
    elif gpio >= 3 && gpio <= 4
      self.write_bit(0x96, gpio - 3, state)
    end
  end

  # Set voltage on DC-DC1/2/3
  def set_dc_voltage(dcdc, voltage)
    if dcdc < 1 || dcdc > 3 return end
    if voltage < 700   voltage = 0
    else voltage = (voltage - 700) / 25
    end

    var            addr = 0x26
    if   dcdc == 2 addr = 0x25
    elif dcdc == 3 addr = 0x27
    end

    self.write1(addr, self.read8(addr) & 0x80 | (voltage & 0x7F))
  end

  # Set charging current
  # 100mA = 0
  # 190mA = 1
  # 280mA = 2
  # 360mA = 3
  # 450mA = 4
  # 550mA = 5
  # 630mA = 6
  # 700mA = 7
  # 780mA = 8
  # 880mA = 9
  # 960mA = 10
  # 1000mA = 11
  # 1080mA = 12
  # 1160mA = 13
  # 1240mA = 14
  # 1320mA = 15
  def set_chg_current(current_code)
    self.write1(0x33, self.read8(0x33) & 0xF0 | (current_code & 0x0F))
  end

  # // Low Volt Level 1, when APS Volt Output < 3.4496 V
  # // Low Volt Level 2, when APS Volt Output < 3.3992 V, then this flag is SET (0x01)
  # // Flag will reset once battery volt is charged above Low Volt Level 1
  # // Note: now AXP192 have the Shutdown Voltage of 3.0V (B100) Def in REG 31H
  def get_warning_level()
    return self.read12(0x47) & 1
  end

  #- trigger a read every second -#
  # def every_second()
  #   if !self.wire return nil end  #- exit if not initialized -#
  # end

  #- display sensor value in the web UI -#
  def web_sensor()
    if !self.wire return nil end  #- exit if not initialized -#
    import string
    var msg = string.format(
             "{s}VBus Voltage{m}%.3f V{e}"..
             "{s}VBus Current{m}%.1f mA{e}"..
             "{s}Batt Voltage{m}%.3f V{e}"..
             "{s}Batt Current{m}%.1f mA{e}"..
             #"{s}Batt Power{m}%.3f{e}"..
             "{s}Temp AXP{m}%.1f °C{e}",
             self.get_vbus_voltage(), self.get_vbus_voltage(),
             self.get_bat_voltage(), self.get_bat_current(),
             #self.get_bat_power(),
             self.get_temp()
            )
    tasmota.web_send_decimal(msg)
  end

  #- add sensor value to teleperiod -#
  # def json_append()
  #   if !self.wire return nil end  #- exit if not initialized -#
  #   # import string
  #   # var ax = int(self.accel[0] * 1000)
  #   # var ay = int(self.accel[1] * 1000)
  #   # var az = int(self.accel[2] * 1000)
  #   # var msg = string.format(",\"MPU6886\":{\"AX\":%i,\"AY\":%i,\"AZ\":%i,\"GX\":%i,\"GY\":%i,\"GZ\":%i}",
  #   #           ax, ay, az, self.gyro[0], self.gyro[1], self.gyro[2])
  #   # tasmota.response_append(msg)
  # end

end

class AXP192_M5Stack_Core2 : AXP192
  def init()
    super(self).init()

    # if true return end    # TODO

    if self.wire
      # Disable vbus hold limit
      self.write1(0x30, self.read8(0x30) & 0x04 | 0x02)

      # AXP192 GPIO1:OD OUTPUT
      self.write1(0x92, self.read8(0x92) & 0xF8)

      # AXP192 GPIO2:OD OUTPUT
      self.write1(0x93, self.read8(0x93) & 0xF8)

      # AXP192 RTC CHG rtc battery charging enabled
      self.write1(0x35, self.read8(0x35) & 0x1C | 0xA2)

      # esp32 power voltage was set to 3.35v
      self.set_esp_voltage(3350)

      # lcd backlight voltage was set to 2.80v
      self.set_lcd_voltage(2800)

      # lcd logic and sdcard voltage preset to 3.3v
      self.set_ldo_voltage(2, 3300)

      # vibrator voltage preset to 2v
      self.set_ldo_voltage(3, 2000)

      # turn on logic and sdcard
      self.set_ldo_enable(2, true)

      # turn on lcd backlight
      self.set_dcdc_enable(3, true)

      # turn green led on
      self.set_led(true)
  
      # set charging current to 100mA
      self.set_chg_current(0) # 0 = 100mA

      # AXP192 GPIO4 - TBC what this does really?
      self.write1(0x95, self.read8(0X95) & 0x72 | 0x84)
  
      # Button parameter setting
      # Current:
      #   Boot time = 512ms
      #   Long key press time setting = 1s
      #   Automatic shutdown function setting when the key duration is longer than the shutdown duration = turn on
      #   PWROK signal delay after power on = 64ms
      #   Shutdown duration setting = 4s
      self.write1(0x34, 0x4C)
  
      # ADC all-on
      # Bit 7: Battery voltage ADC enable
      # Bit 6: Battery current ADC enable
      # Bit 5: ACIN voltage ADC enable
      # Bit 4: ACIN current ADC enable
      # Bit 3: VBUS voltage ADC enable
      # Bit 2: VBUS current ADC enable
      # Bit 1: APS voltage ADC enable
      # Bit 0: TS pin ADC function enable
      self.write1(0x82, 0xFF)
  
      # Reset LCD Controller
      self.set_lcd_reset(false)
      self.get_tasmota().delay(100)   # wait for 100ms
      self.set_lcd_reset(true)
      self.get_tasmota().delay(100)   # wait for 100ms

      # bus power mode_output
      self.set_buf_power_mode(false)
    end
  end

  # set ESP voltage on DCDC1
  def set_esp_voltage(voltage)
    if voltage >= 3000 && voltage <= 3400
      self.set_dc_voltage(1, voltage)
    end
  end

  # set LCD backlight voltage on DCDC3
  def set_lcd_voltage(voltage)
    if voltage >= 2500 && voltage <= 3300
      self.set_dc_voltage(3, voltage)
    end
  end

  # set state of the green led, GPIO 1
  def set_led(state)
    self.write_gpio(1, !state)
  end

  # LCD Controller Reset pin
  def set_lcd_reset(state)
    self.write_gpio(4, state)
  end

  # Speaker enable
  def set_speaker_enable(state)
    self.write_gpio(2, state)
  end

  # Bus Power Mode
  def set_buf_power_mode(state)
    if (state)
      self.write1(0x12, self.read8(0x12) & 0xBF)          # set EXTEN to disable 5v boost
      self.write1(0x90, self.read8(0x90) & 0xF8 | 0x01)   # set GPIO0 to float, using enternal pulldown resistor to enable supply from BUS_5VS
    else
      self.write1(0x91, self.read8(0x91) & 0x0F | 0xF0)
      self.write1(0x90, self.read8(0x90) & 0xF8 | 0x02)   # set GPIO0 to LDO OUTPUT , pullup N_VBUSEN to disable supply from BUS_5V
      self.write1(0x12, self.read8(0x12) | 0x40)          # set EXTEN to enable 5v boost
    end
  end
end

axp = AXP192_M5Stack_Core2()

tasmota.add_driver(axp)

#-------------------------------------------------------------
 - Specialized driver for AXP2101 of M5Core2_v1_1
 -------------------------------------------------------------#
class AXP2101_M5Core2_v1_1 : AXP2101
  def init()
    super(self).init()
    print("AXP2101: init M5Core2 v1.1")
    
    if self.wire
      if (!self.begin())
        print("AXP2101: Warning - Chip verification failed")
      end
      
      # Compact initialization
      #self.write8(0x90, 0xBE)           # LDOS ON/OFF control 0
      self.write8(0x90, 0x1A)
      self.write8(0x2B, 0x0F)           # Disable fast wake and fast power on, disable dldo1&2 fast power on.
      self.write8(0x92, 0x00)           # ALDO1 off
      self.write8(0x93, 28)             # ALDO2 on, 3.3V (33-5=28)
      self.write8(0x94, 0x00)           # ALDO3 off (Speaker off)
      self.write8(0x95, 28)             # ALDO4 on, 3.3V
      self.write8(0x96, 0x00)           # BLDO1 off (Backlight)
      self.write8(0x99, 0x00)           # DLDO1 off (Vibration off)
      self.write8(0x50, 0x00)           # TS pin Ctrl. All off, since no battery temp monitoring.
      self.write8(0x30, 0x1D)           # All ADC enabled, except GP_adc and TS pin
      
      self.write8(0x27, 0x00)           # PowerKey timing
      self.write8(0x22, 0x06)           # PWROFF_EN
      self.write8(0x10, 0x30)           # PMU config
      self.write8(0x12, 0x00)           # BATFET disabled
      self.write8(0x68, 0x01)           # Battery detection
      self.write8(0x69, 0x35)           # CHGLED

      self.set_pre_charge_current(200)
      self.set_charge_current(300)
      self.set_termination_current_limit(25)
      self.set_charge_voltage(4200)

      if self.get_vbus_good()
        self.set_ldo_voltage(5, 3300)   # BOOST on 5V rail if VBUS present
      end

      tasmota.add_rule_once("System#Init", /-> self.config_INA3221())

      tasmota.add_driver(self)
    end
  end

  def config_INA3221()
     if tasmota.i2c_enabled(72) && (wire2.detect(64) || wire1.detect(64))
       tasmota.cmd("sensor100 1,0.01,0.01,0.01") # Set sense resistor values for INA3221
     end
  end

  def set_lcd_voltage(voltage)
    voltage = (voltage < 2500) ? 2500 : ((voltage > 3300) ? 3300 : voltage)
    self.set_ldo_voltage(4, voltage)
  end

  def set_speaker_enable(state)
    self.set_ldo_voltage(2, state ? 3300 : 0)
  end
  
  def set_vibration_enable(state)
    self.set_dldo_voltage(0, state ? 3300 : 0)
  end

  def set_displaydimmer(x)
    var v = tasmota.scale_uint(x, 0, 100, 2500, 3300)
    self.set_lcd_voltage(v)
  end

  def display(cmd, idx, payload, raw)
    if cmd == "dim" || cmd == "power"
      self.set_displaydimmer(idx)
    end
  end

end

return AXP2101_M5Core2_v1_1()

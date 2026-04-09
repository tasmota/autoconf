#-------------------------------------------------------------
 - Generic driver for AXP2101 power management IC
 -------------------------------------------------------------#
 class AXP2101 : I2C_Driver
  var status_register # Array for status registers
  var _init          # Initialization status
  
  # Current power state - 1=inserted, 0=removed
  var vbus_present
  var bat_present
  var last_irq_status  # Cache of last interrupt status to detect changes
  
  # IRQ Constants
  # Register 0 (IRQSTAT0 = 0x48) - Bits 0-7
  #static var IRQ_WARNING_LEVEL2      = 0x0080  # Bit 7
  #static var IRQ_WARNING_LEVEL1      = 0x0040  # Bit 6
  #static var IRQ_GAUGE_WDT_TIMEOUT   = 0x0020  # Bit 5
  #static var IRQ_GAUGE_NEW_SOC      = 0x0010  # Bit 4
  #static var IRQ_BAT_CHG_OVER_TEMP  = 0x0008  # Bit 3
  #static var IRQ_BAT_CHG_UNDER_TEMP = 0x0004  # Bit 2
  #static var IRQ_BAT_OVER_TEMP      = 0x0002  # Bit 1
  #static var IRQ_BAT_UNDER_TEMP     = 0x0001  # Bit 0
  
  # Register 1 (IRQSTAT1 = 0x49) - Bits 8-15
  static var IRQ_VBUS_INSERT         = 0x8000  # Bit 15 (7)
  static var IRQ_VBUS_REMOVE         = 0x4000  # Bit 14 (6)
  static var IRQ_BAT_INSERT          = 0x2000  # Bit 13 (5)
  static var IRQ_BAT_REMOVE          = 0x1000  # Bit 12 (4)
  #static var IRQ_PKEY_SHORT_PRESS    = 0x0800  # Bit 11 (3)
  #static var IRQ_PKEY_LONG_PRESS     = 0x0400  # Bit 10 (2)
  #static var IRQ_PKEY_NEGATIVE_EDGE = 0x0200  # Bit 9  (1)
  #static var IRQ_PKEY_POSITIVE_EDGE = 0x0100  # Bit 8  (0)

  # Register 2 (IRQSTAT2 = 0x4A) - Bits 16-23
  #static var IRQ_WDT_EXPIRE         = 0x800000  # Bit 23 (7)
  #static var IRQ_LDO_OVER_CURR       = 0x400000  # Bit 22 (6)
  #static var IRQ_BAT_CHG_DONE        = 0x100000  # Bit 20 (4)
  static var IRQ_BAT_CHG_START       = 0x080000  # Bit 19 (3)
  #static var IRQ_DIE_OVER_TEMP       = 0x040000  # Bit 18 (2)
  #static var IRQ_CHARGER_TIMER       = 0x020000  # Bit 17 (1)
  #static var IRQ_BAT_OVER_VOLTAGE    = 0x010000  # Bit 16 (0)

  # Register addresses
  static var IRQEN0 = 0x40
  static var IRQEN1 = 0x41
  static var IRQEN2 = 0x42
  static var IRQSTAT0 = 0x48
  static var IRQSTAT1 = 0x49
  static var IRQSTAT2 = 0x4A

  # Lookup tables
  static var _pre_charge_table = [0, 25, 50, 75, 100, 125, 150, 175, 200, 255]
  static var _charge_table = [125, 150, 175, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 255]
  static var _charge_voltage_table = [5000, 4000, 4100, 4200, 4350, 4400]  
  static var _term_current_table = [0,25,50,75,100,125,150,175,200]
  
  def init(addr)
    if (addr == nil)  addr = 0x34   end   # default address is 0x34
    super(self).init("AXP2101", addr)
    self.status_register = nil
    self._init = false
    
    # Initialize power state (assume present until told otherwise)
    self.vbus_present = 1
    self.bat_present = 1
    self.last_irq_status = 0
  end

  def begin()
    var val = self.read8(0x03)
    self._init = (val == 0x4A)
    return self._init
  end

  def battery_present()
    return bool(self.read8(0x00) & 0x08)
  end

  def get_battery_charging_status()
    var val = (self.read8(0x01) >> 5) & 0x03
    return (val == 1) ? 1 : ((val == 2) ? -1 : 0)
  end

  def is_charging()
    return (self.read8(0x01) & 0x60) == 0x20
  end 
  
  def get_battery_level()
    return self.read8(0xA4)
  end

  def get_internal_temperature()
    return (22 + (7274 - self.read14bitadc(0x3C)) / 20.0)
  end

  def get_ts_voltage()
    var volt = self.read14bitadc(0x36)
    if (volt >= 16375)  return 0.0  end
    return volt / 2000.0
  end

  def get_vsys_voltage()
    var vsys = self.read14bitadc(0x3A)
    if (vsys >= 16375) return 0.0 end
    return vsys / 1000.0
  end

  def get_bat_voltage()
    return ((self.read16(0x34) & 0x1FFF) / 1000.0)
  end
  
  def get_vbus_good()
    return bool(self.read8(0x00) & 0x20)
  end
  
  def get_vbus_voltage()
    if (!self.get_vbus_good()) return 0.0   end
    var vbus = self.read14bitadc(0x38)
    if (vbus >= 16375)   return 0.0    end
    return vbus / 1000.0
  end

  def power_off()
    var reg_val = self.read8(0x10)
    self.write8(0x10, reg_val | 0x01)
  end

  def set_adc_state(enable)
    self.write8(0x30, enable ? 0x3F : 0x03)
  end

  # 0=ALDO1 ~ 3=ALDO4 / 4=BLDO1 / 5=BLDO2
  def set_ldo_voltage(num, voltage)
    if (num < 0 || num > 5)    return  end
    var reg_volt = num + 0x92
    voltage -= 500
    var val = (voltage < 0) ? 0 : (voltage / 100)
    if (val > 0x1E)   val = 0x1E    end
    self.write8(reg_volt, val)

    var reg90bit = 1 << num
    if (voltage < 0)
      self.write8(0x90, self.read8(0x90) & ~reg90bit)
    else
      self.write8(0x90, self.read8(0x90) |  reg90bit)
    end
  end
  
  def _set_ldo(num, voltage)
    return self.set_ldo_voltage(num, voltage)
  end

  def set_dldo_voltage(num, voltage)
    if (num < 0 || num > 1)    return  end
    var reg_volt = num + 0x99
    voltage -= 500
    var val = (voltage < 0) ? 0 : (voltage / (num ? 50 : 100))
    if (val > (num ? 0x13 : 0x1C))  val = num ? 0x13 : 0x1C   end
    self.write8(reg_volt, val)

    var reg = 0x90 + num
    var bit = num ? 0x01 : 0x80
    if (voltage < 0)
      self.write8(reg, self.read8(reg) & ~bit)
    else
      self.write8(reg, self.read8(reg) |  bit)
    end
  end
  
  def _set_dldo(num, voltage)
    return self.set_dldo_voltage(num, voltage)
  end

  def get_ldo_enable(num)
    if (num > 5) return false end
    var reg90bit = 1 << num
    return bool(self.read8(0x90) & reg90bit)
  end

  def set_battery_charge(enable)
    var val = self.read8(0x18)
    self.write8(0x18, (val & 0xFD) | ((enable ? 1 : 0) << 1))
  end

  def set_pre_charge_current(max_mA)
    if (max_mA > 200)   max_mA = 200    end
    var i = 0
    var table = self._pre_charge_table 
    while (i < size(table) && table[i] <= max_mA)
      i += 1
    end
    if (i > 0) i -= 1 end
    self.write8(0x61, i)
  end

  def set_charge_current(max_mA)
    max_mA /= 5
    if (max_mA > 200)   max_mA = 200    end
    var i = 0
    var table = self._charge_table
    while (i < size(table) && (table[i] / 5) <= max_mA)
      i += 1
    end
    i += 4
    self.write8(0x62, i)
  end

  def set_charge_voltage(mV)
    var i = 0
    var table = self._charge_voltage_table
    while (i < size(table) && table[i] != mV)
      i += 1
    end
    if (i >= size(table)) return false end
    self.write8(0x64, i)
    return true
  end

  def get_charge_voltage_mV()
    var i = self.read8(0x64) & 0x07
    var table = self._charge_voltage_table
    if (i < size(table)) return table[i] end
    return nil
  end

  def set_termination_current_limit(mA)
    var table = self._term_current_table
    var i = 0
    while (i < size(table) && table[i] <= mA)
      i += 1
    end
    if (i > 0) i -= 1 end

    var reg = self.read8(0x63)   # Bits [3:0]=ITERM, Bit4=Enable
    reg = (reg & 0xE0) | (i & 0x0F) | ( (i>0) ? 0x10 : 0x00 )
    return self.write8(0x63, reg)
  end

  def get_termination_current_limit()
    var reg = self.read8(0x63)
    var en  = (reg & 0x10) != 0
    var idx = reg & 0x0F
    var table = self._term_current_table
    if (idx < size(table)) return en ? table[idx] : 0 end
    return nil
  end

  def bit_on(reg, bit)
    var val = self.read8(reg)
    self.write8(reg, val | bit)
  end
  
  def bit_off(reg, bit)
    var val = self.read8(reg)
    self.write8(reg, val & (~bit))
  end

  # IRQ functions
 
  def get_irq_statuses()
    self.status_register = [0, 0, 0]
    self.status_register[0] = self.read8(self.IRQSTAT0)
    self.status_register[1] = self.read8(self.IRQSTAT1)
    self.status_register[2] = self.read8(self.IRQSTAT2)
    return (self.status_register[2] << 16) | (self.status_register[1] << 8) | self.status_register[0]
  end
  
  def clear_irq_statuses()
    for i : 0..2
      self.write8(self.IRQSTAT0 + i, 0xFF)
    end
    if (self.status_register != nil)
      self.status_register = [0, 0, 0]
    end
  end

  def check_irq(irq_constant)
    if (self.status_register == nil) return false end
    var reg_idx = 0
    var mask = irq_constant
    
    # Determine which register to check based on constant value
    if (irq_constant & 0xFF0000)
      reg_idx = 2
      mask = irq_constant >> 16
    elif (irq_constant & 0x00FF00)
      reg_idx = 1
      mask = irq_constant >> 8
    else
      reg_idx = 0
      mask = irq_constant
    end
    
    return (self.status_register[reg_idx] & mask) != 0
  end
   
  # Interrupt handler - updates current power state based on insert/remove events
  def handle_interrupts()
    var status = self.get_irq_statuses()
    
    # Calculate what changed (XOR shows bits that flipped)
    var changed = status ^ self.last_irq_status
    
    # Mask for our monitored interrupts
    var power_mask = self.IRQ_VBUS_INSERT | self.IRQ_VBUS_REMOVE | 
                     self.IRQ_BAT_INSERT | self.IRQ_BAT_REMOVE | 
                     self.IRQ_BAT_CHG_START
    
    # Check if any of our monitored interrupts changed
    if (changed & power_mask) == 0
      return
    end
    
    # Process only the changed power interrupts
    if (changed & self.IRQ_VBUS_INSERT) && self.check_irq(self.IRQ_VBUS_INSERT, status)
      #print("AXP2101: VBUS inserted")
      self.vbus_present = 1
    elif (changed & self.IRQ_VBUS_REMOVE) && self.check_irq(self.IRQ_VBUS_REMOVE, status)
      #print("AXP2101: VBUS removed")
      self.vbus_present = 0
    end
    
    if (changed & self.IRQ_BAT_INSERT) && self.check_irq(self.IRQ_BAT_INSERT, status)
      #print("AXP2101: Battery inserted")
      self.bat_present = 1
    elif (changed & self.IRQ_BAT_REMOVE) && self.check_irq(self.IRQ_BAT_REMOVE, status)
      #print("AXP2101: Battery removed")
      self.bat_present = 0
    end
    
    if (changed & self.IRQ_BAT_CHG_START) && self.check_irq(self.IRQ_BAT_CHG_START, status)
      #print("AXP2101: Charging started")
      self.bat_present = 1
    end
    
    # Update cached status
    self.last_irq_status = status
  end

  def read14bitadc(reg)
    return self.read16(reg) & 0x3FFF
  end

  # Get all power values - returns map with current readings
  def get_power_values()
    var vbus = 0.0
    var vsys = self.get_vsys_voltage()
    var vbat = 0.0
    var lvl = 0
    var chg = 0
    var temp = self.get_internal_temperature()
    
    if (self.vbus_present)
      vbus = self.get_vbus_voltage()
    end
    
    if (self.bat_present)
      vbat = self.get_bat_voltage()
      lvl = self.get_battery_level()
      chg = self.is_charging() ? 1 : 0
    end
    
    return {'vbus': vbus, 'vsys': vsys, 'vbat': vbat, 'lvl': lvl, 'chg': chg, 'temp': temp}
  end

  # --- Web-UI ---
  def web_sensor()
    if !self.wire return nil end
    var v = self.get_power_values()
    
    var msg = format(
        "{s}VBUS Voltage{m}%.3f V{e}"
      .."{s}VSYS Voltage{m}%.3f V{e}"
      .."{s}Bat Voltage{m}%.3f V{e}"
      .."{s}Bat Level{m}%d %%{e}"
      .."{s}Charging{m}%s{e}"
      .."{s}AXP Temperature{m}%.1f &deg;C{e}",
        v['vbus'], v['vsys'], v['vbat'], v['lvl'], (v['chg'] ? "Yes" : "No"), v['temp']
    )
    tasmota.web_send_decimal(msg)
  end

  def json_append()
    if !self.wire return nil end
    self.handle_interrupts()
    var v = self.get_power_values()
    
    var msg = format(
      ",\"AXP2101\":{\"VBUS\":%.3f,\"VSYS\":%.3f,\"VBAT\":%.3f,\"Level\":%d,\"Charging\":%d,\"Temp\":%.1f}",
      v['vbus'], v['vsys'], v['vbat'], v['lvl'], v['chg'], v['temp']
    )
    tasmota.response_append(msg)
  end
end
return AXP2101

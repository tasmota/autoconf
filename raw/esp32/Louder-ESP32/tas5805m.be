# TAS5805M DAC Driver for Berry/Tasmota
# Based on: https://github.com/sonocotta/esp32-tas5805m-dac

class TAS5805M
    # Louder-ESP32 I2S DAC Driver for TAS5805M
    static i2c_addr = 0x2D  # Default I2C address
    static pdn_pin = 33     # Power Down Pin (GPIO 33)
    static fault_pin = 34   # Fault Pin (GPIO 34, optional)
    var i2c

    # Register definitions
    static PAGE_REG = 0x00
    static RESET_REG = 0x01
    static DEVICE_CTRL_1 = 0x02
    static DEVICE_CTRL_2 = 0x03
    static SIG_CH_CTRL = 0x28
    static SAP_CTRL1 = 0x33
    static SAP_CTRL2 = 0x34
    static SAP_CTRL3 = 0x35
    static FS_MON = 0x37
    static BCK_MON = 0x38
    static CLKDET_STATUS = 0x39
    static DIG_VOL_CTRL = 0x4C
    static DIG_VOL_CTRL2 = 0x4D
    static DIG_VOL_CTRL3 = 0x4E
    static AUTO_MUTE_CTRL = 0x50
    static AUTO_MUTE_TIME = 0x51
    static ANA_CTRL = 0x53
    static AGAIN_CTRL = 0x54
    static BQ_WR_CTRL1 = 0x5C
    static ADR_PIN_CTRL = 0x60
    static ADR_PIN_CONFIG = 0x61
    static DSP_MISC = 0x66
    static DIE_ID = 0x67
    static POWER_STATE = 0x68
    static AUTOMUTE_STATE = 0x69
    static PHASE_CTRL = 0x6A
    static SS_CTRL0 = 0x6B
    static SS_CTRL1 = 0x6C
    static SS_CTRL2 = 0x6D
    static SS_CTRL3 = 0x6E
    static SS_CTRL4 = 0x6F
    static CHAN_FAULT = 0x70
    static GLOBAL_FAULT1 = 0x71
    static GLOBAL_FAULT2 = 0x72
    static OT_WARNING = 0x73
    static PIN_CONTROL1 = 0x74
    static PIN_CONTROL2 = 0x75
    static MISC_CONTROL = 0x76
    static FAULT_CLEAR = 0x78

    static CFG_META_DELAY = 254

    # Minimal register configuration sequence for TAS5805M
    # could be loaded from file or defined here
    # Use CFG_META_DELAY for delays (value = ms)
    static tas5805m_registers = bytes(
        # RESET
        "0000"
        "7f00"
        "0302"
        "0111"
        "0302"
        "fe0a" # CFG_META_DELAY
        "0300"
        "4601"
        "0302"
        "610b"
        "6001"
        "7d11"
        "7eff"
        "0001"
        "5105"
        # Register Tuning
        "0000"
        "7f00"
        "0200"
        "3000"
        "4c30"
        "5300"
        "5400"
        "0303"
        "7880")

    # Constructor
    def init()
        self.i2c = tasmota.wire_scan(self.i2c_addr)
        if self.i2c == nil
            log("TAS5805M: I2C device not found at address 0x{self.i2c_addr:02X}",1)
            return false
        end

        # Configure PDN pin as output
        gpio.pin_mode(self.pdn_pin, gpio.OUTPUT)

        # Configure Fault pin as input (if defined)
        if self.fault_pin >= 0
            gpio.pin_mode(self.fault_pin, gpio.INPUT_PULLUP)
        end

        # Initialize chip
        log(f"TAS5805M: Initializing I2C device at address 0x{self.i2c_addr:02X}")
        self.hardware_reset()
        log("TAS5805M: Device reset complete")
        self.device_init()
        log("TAS5805M: Device initialized successfully")
        self.transmit_registers(self.tas5805m_registers, size(self.tas5805m_registers))
        tasmota.add_driver(self)
        log("TAS5805M: Driver added successfully")
        self.add_commands()
        log("TAS5805M: Commands i2smute and i2svol added successfully")
    end


    def audio(cmd, idx, payload, raw)
        if cmd == "power"
            self.set_power(idx)
            log(f"TAS5805M: Power {idx}")
        end
    end

    # Hardware reset
    def hardware_reset()
        gpio.digital_write(self.pdn_pin, 0)
        tasmota.delay(20)
        gpio.digital_write(self.pdn_pin, 1)
        tasmota.delay(200)
    end

    # Write I2C register
    def write_register(reg, value)
        return self.i2c.write(self.i2c_addr, reg, value, 1)
    end

    # Read I2C register
    def read_register(reg)
        return self.i2c.read(self.i2c_addr, reg, 1)
    end

    def transmit_registers(conf_buf)
        var i = 0
        var ret = true
        var sz = size(conf_buf)
        log("tas5805m_transmit_registers: enter",4)
        while i < sz
            var reg = conf_buf[i]
            var val = conf_buf[i + 1]
            if reg == self.CFG_META_DELAY
                # Delay in milliseconds
                tasmota.delay(val)
            else
                # Write register
                ret = self.write_register(reg, val)
                log(f"\t0x{reg:02X} <- 0x{val:02X}",4)
            end
            i += 2
        end
        if !ret
            log("tas5805m_transmit_registers: Failed to load configuration to tas5805m")
            return false
        end
        log(f"tas5805m_transmit_registers: leave; wrote {sz} registers",4)
        return true
    end

    # Device initialization
    def device_init()
        # Perform reset
        self.write_register(self.RESET_REG, 0x01)
        tasmota.delay(100)

        # Configure device control
        self.write_register(self.DEVICE_CTRL_1, 0x02)
        self.write_register(self.DEVICE_CTRL_2, 0x03)

        # Signal channel control
        self.write_register(self.SIG_CH_CTRL, 0x00)

        # Configure SAP control
        self.write_register(self.SAP_CTRL1, 0x00)  # I2S standard
        self.write_register(self.SAP_CTRL2, 0x10)  # 16-bit
        self.write_register(self.SAP_CTRL3, 0x00)

        # Disable auto-mute
        self.write_register(self.AUTO_MUTE_CTRL, 0x00)

        # Analog control
        self.write_register(self.ANA_CTRL, 0x00)

        # Power-up
        self.write_register(self.DEVICE_CTRL_2, 0x03)

        tasmota.delay(100)
    end

    # Set volume (0-255)
    def set_volume(volume)
        if volume > 255 volume = 255 end
        if volume < 0 volume = 0 end

        # Convert volume to dB (-103.5dB to 24dB)
        # 0 = -103.5dB, 255 = 24dB
        var vol_db = volume

        self.write_register(self.DIG_VOL_CTRL, vol_db)
        self.write_register(self.DIG_VOL_CTRL2, vol_db)
    end

    # Read volume
    def get_volume()
        return self.read_register(self.DIG_VOL_CTRL)
    end

    # Set the volume as percentage [0..124], where 100 is 0 dB, 0 is mute
    def set_volume_pct(vol)
        # Clamp to allowed range
        if vol < 0
            vol = 0
        end
        if vol > 124
            vol = 124
        end

        # Convert to register value: 0 = mute, 100 = 0 dB, 124 = max
        # Formula: reg = vol == 0 ? 255 : (-2 * vol + 248)
        var reg_val = vol == 0 ? 255 : (-2 * vol + 248)
        self.set_volume(reg_val)
        return reg_val
    end

    # Get the volume as percentage [0..124], where 100 is 0 dB, 0 is mute
    def get_volume_pct()
        var reg_val = self.get_volume()
        # Formula: pct = reg_val >= 248 ? 0 : (248 - reg_val) / 2
        if reg_val >= 248
            return 0
        else
            return (248 - reg_val) / 2
        end
    end

    # Set mute
    def set_mute(mute)
        var ctrl = self.read_register(self.DEVICE_CTRL_2)
        if mute
            ctrl = ctrl | 0x08  # Set mute bit
        else
            ctrl = ctrl & 0xF7  # Clear mute bit
        end
        self.write_register(self.DEVICE_CTRL_2, ctrl)
    end

    # Read mute status
    def get_mute()
        var ctrl = self.read_register(self.DEVICE_CTRL_2)
        return (ctrl & 0x08) != 0
    end

    # Set power state
    def set_power(power_on)
        if power_on
            self.write_register(self.DEVICE_CTRL_2, 0x03)  # Power up
        else
            self.write_register(self.DEVICE_CTRL_2, 0x01)  # Power down
        end
    end

    # Read power state
    def get_power_state()
        return self.read_register(self.POWER_STATE)
    end

    # Read sample rate
    def get_sample_rate()
        var fs_mon = self.read_register(self.FS_MON)
        var rates = [8000, 16000, 22050, 24000, 32000, 44100, 48000, 88200, 96000, 176400, 192000]

        if fs_mon < size(rates)
            return rates[fs_mon]
        end
        return 0
    end

    # Read BCK ratio
    def get_bck_ratio()
        return self.read_register(self.BCK_MON)
    end

    # Read fault status
    def get_fault_status()
        return {
            'Channel': self.read_register(self.CHAN_FAULT),
            'Global1': self.read_register(self.GLOBAL_FAULT1),
            'Global2': self.read_register(self.GLOBAL_FAULT2)
        }
    end

    # Clear fault status
    def clear_fault()
        self.write_register(self.FAULT_CLEAR, 0x80)
        tasmota.delay(10)
        self.write_register(self.FAULT_CLEAR, 0x00)
    end

    # Set analog gain
    def set_analog_gain(gain)
        # Gain: 0 = 19.2dBV, 1 = 20.7dBV, 2 = 22.2dBV, 3 = 23.7dBV
        if gain > 3 gain = 3 end
        if gain < 0 gain = 0 end

        var ana_ctrl = self.read_register(self.ANA_CTRL)
        ana_ctrl = (ana_ctrl & 0xFC) | gain
        self.write_register(self.ANA_CTRL, ana_ctrl)
    end

    # Read analog gain
    def get_analog_gain()
        var ana_ctrl = self.read_register(self.ANA_CTRL)
        return ana_ctrl & 0x03
    end

    # Read device ID
    def get_device_id()
        return self.read_register(self.DIE_ID)
    end

    # Read auto-mute state
    def get_auto_mute_state()
        return self.read_register(self.AUTOMUTE_STATE)
    end

    # Read fault pin status (if configured)
    def get_fault_pin()
        if self.fault_pin >= 0
            return gpio.digital_read(self.fault_pin)
        end
        return nil
    end

    def status()
        var result = {"Status": {
            "DeviceID": self.get_device_id(),
            "PowerState": self.get_power_state(),
            "Volume": self.get_volume(),
            "Mute": self.get_mute(),
            "SampleRate": self.get_sample_rate(),
            "BCKRatio": self.get_bck_ratio(),
            "AnalogGain": self.get_analog_gain(),
            "AutoMuteState": self.get_auto_mute_state(),
            "FaultStatus": self.get_fault_status()
        }}
        if self.fault_pin >= 0
            result["FaultPin"] = self.get_fault_pin()
        end
        log(f"TAS5805M = {result}")
    end

    def i2smute(cmd, idx, payload, raw)
        log(f"TAS5805M: i2smute command received with raw={raw}",3)
        if raw != nil
            self.set_mute(raw != 0)  # idx is 0 for unmute
        end
        tasmota.resp_cmnd(format("{'i2smute':%i}}",self.get_mute()))
    end

    def i2svol(cmd, idx, payload, raw)
        if raw
            log(f"TAS5805M: set new volume: {raw}")
            self.set_volume_pct(raw)
        end
        tasmota.resp_cmnd(format("{'i2svol':%i}}",self.get_volume_pct()))
    end

    def add_commands()
        tasmota.add_cmd('i2smute', /c,i,p,r->self.i2smute(c,i,p,r))
        tasmota.add_cmd('i2svol', /c,i,p,r->self.i2svol(c,i,p,r))
    end
end

# Execute at Tasmota startup
dac = TAS5805M()

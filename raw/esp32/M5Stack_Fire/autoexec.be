# setup the 3 physical buttons

import global
import introspect

if introspect.get(global, 'lv')
  lv.start()

  import lv_touch_3_buttons

  var lv_btn3 = lv_touch_3_buttons(gpio.pin(gpio.INPUT, 0), gpio.pin(gpio.INPUT, 1), gpio.pin(gpio.INPUT, 2), lv_touch_3_buttons.ACTIVE_LOW)
  tasmota.add_driver(lv_btn3)
end

# mpu accelerator
import mpu_accel

global.accelerator = mpu_accel()


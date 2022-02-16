# setup the 3 physical buttons

import sys
var path = sys.path()

path.push(wd)
import lv_touch_3_buttons
path.pop()

var lv_btn3 = lv_touch_3_buttons(gpio.pin(gpio.INPUT, 0), gpio.pin(gpio.INPUT, 1), gpio.pin(gpio.INPUT, 2), lv_touch_3_buttons.ACTIVE_LOW)
tasmota.add_driver(lv_btn3)


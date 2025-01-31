; Waveshare ESP32C6 LCD 1.47
; Use LVGL build
Template {"NAME":"Waveshare ESP32C6 LCD 1.47","GPIO":[1,1,1,1,6720,672,704,736,1376,1,1,1,1,1,768,800,1,1,1,1,1,1024,992,1,0,0,6210,0,0,0,0],"FLAG":0,"BASE":1}
Module 0
; We can't use Pixels and PixelType commands because the template is not yet active
; so we use Berry helpers instead to emulate 'Pixels 1' and 'PixelType 2'
Br tasmota.settings.light_pixels = 1
Br tasmota.settings.light_pixels_order = 2
Br tasmota.settings.light_pixels_rgbw = 0

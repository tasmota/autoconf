# 01space 0.42" OLED demo
lv.start()

devicename = tasmota.cmd("DeviceName")["DeviceName"]

hres = lv.get_hor_res()      
vres = lv.get_ver_res()      

scr = lv.scr_act()            # default screen object
f = lv.load_font("A:unscii8l.font")
if f != nil scr.set_style_text_font(f, lv.PART_MAIN | lv.STATE_DEFAULT) end

scr.set_style_bg_color(lv.color(0x000000), lv.PART_MAIN | lv.STATE_DEFAULT)
scr.set_style_text_color(lv.color(0xFFFFFF), lv.PART_MAIN | lv.STATE_DEFAULT)  # text color #FFFFFF

logo = lv.img(scr)
logo.set_style_img_recolor_opa(255, lv.PART_MAIN | lv.STATE_DEFAULT)
logo.set_style_img_recolor(lv.color(lv.COLOR_WHITE), lv.PART_MAIN | lv.STATE_DEFAULT)
logo.set_tasmota_logo()
logo.set_pos(-25,-25)
logo.set_zoom(64)
logo.refr_size()
logo.refr_pos() 

#- Upper state line -#
stat_line = lv.label(scr)
stat_line.set_long_mode(lv.LABEL_LONG_SCROLL)                                        # auto scrolling if text does not fit
stat_line.set_pos(25,1)
stat_line.set_width(hres-25)
stat_line.set_align(lv.TEXT_ALIGN_LEFT)                                              # align text left
stat_line.set_text(devicename)
stat_line.refr_size()                                                                # new in LVGL8
stat_line.refr_pos()                                                                 # new in LVGL8

#- display wifi strength indicator icon (for professionals ;) -#
widg_line = lv.label(scr)
widg_line.set_long_mode(lv.LABEL_LONG_SCROLL)                                        # auto scrolling if text does not fit
widg_line.set_pos(1,20)
widg_line.set_width(hres)
widg_line.set_align(lv.TEXT_ALIGN_LEFT)  
widg_line.refr_size()                                                                # new in LVGL8
widg_line.refr_pos()                                                                 # new in LVGL8

wifi_icon = lv_wifi_arcs_icon(widg_line)    # the widget takes care of positioning and driver stuff
clock_icon = lv_clock_icon(widg_line)

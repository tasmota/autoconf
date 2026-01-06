# Waveshare ESP32-S3-Touch-LCD-169

## DISPLAY ROTATION

The "display.ini" is written for a portrait orientation with height of 280 and a width of 240 pixel.

It is possible to rotate the display with the ":r,X" command.

To rotate the display and also the touch coordinates replace then ":r,0" command with ":r,1" to rotate by 90 degrees.

There are 4 possible values for the X in ":r,X"

0: no rotation, 240 x 280
1: 90 degree, 280 x 240
2: 180 degree, 240 x 280 (upside down)
3: 270 degree, 280 x 240

## TOUCH SCREEN

There are some commented DEBUG commands in the TOUCH section of the "display.ini".

To enable them just remove the semicolon in front and there should be a message in the log when the specific section is called as shown in the following example

---
18:22:48.316 UTDBG 1: 00 : b5,0a,52,44
18:22:48.318 UTDBG 4: 01 : b5,0a,52,44
18:22:48.318 UTI: CST816T initialized
---

Have fun

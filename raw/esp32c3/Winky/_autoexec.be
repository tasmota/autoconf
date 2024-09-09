# This file does nothing it just contains some
# examples to suit your needs depending on project
# It will be copied into filesystem to be editable
# =====================================================

# Set auto timezone
#tasmota.cmd("Backlog0 Timezone 99; TimeStd 0,0,10,1,3,60; TimeDst 0,0,3,1,2,120")

# Set Teleinfo in legacy (historique) mode at 1200 baud.
#tasmota.cmd("EnergyConfig Historique")

# Set Teleinfo in Standar mode at 9600 baud.
#tasmota.cmd("EnergyConfig Standard")

# Set Teleinfo to autodetect mode (standard or historique)
#tasmota.cmd("EnergyConfig automode")

# Set LED brightness to 75%, in sleep mode it will be bright/2
# 0 for Green LED and 1 for Period Indicator (blue, white or red)
#tasmota.cmd("EnergyConfig bright=75")
#tasmota.cmd("EnergyConfig period=1")

# Disable Boot Loop Detection
#tasmota.cmd("SetOption65 1")

# Allow to display more Energy Values on WebUI
#tasmota.cmd("WebSensor3 1")

# Allow to display Winky Internal Voltages
# Linky output, Super Capacitor and USB
#tasmota.cmd("WebSensor2 1")

# This driver is not used anymore since Winky is now provided with Nicolas's Firmware 
# that does all the dirty job and have so much features, please check this out
# https://github.com/NicolasBernaerts/tasmota/tree/master/teleinfo
# Driver code has been let there for study and example purposes but been disabled
# by commented following line  

# load Winky teleinfo driver
#load("teleinfo.be")

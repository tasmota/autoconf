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

# Disable Boot Loop Detection
#tasmota.cmd("SetOption65 1")

# Avoid conflict between native WS2812 and Berry control
# disables native WS2812 (default Scheme is 0)
#tasmota.cmd("Scheme 14")

#!/bin/bash

# Color used in the bar (extracted from .Xresources)
# *     0 : black
# *     1 : red
# *     2 : green
# *     3 : yellow
# *     4 : blue
# *     5 : magenta
# *     6 : cyan
# *     7 : white

# unified colors
bg="8"
fg="9"
hl="8"

# separator
sp=" "

# path to executable
bar="/usr/bin/bar -f"

#info icons (from stlarch_font package. use gbdfed to view/modify font)
i_arch='\ue0a1'     # arch logo
i_pkgs='\ue14d'   # pacman
i_pkgs='\ue0aa'     # pacman ghost
i_mail='\ue072'     # mail icon
i_wifi='\ue0f0'     # signal
i_netw='\ue149'     # wired
i_time='\ue017'     # clock
i_batt='\ue040'     # thunder
i_sect='\ue10c'     # power (on A/C)
i_load='\ue021'     # micro chip
i_memy='\ue145'     # floppy
i_musk='\ue04d'     # headphones
i_alsa='\ue05d'     # speaker

# workspace icons / names     (α β γ δ ε ζ η θ ι κ λ)
i_trm=$(echo -e '0')
i_web=$(echo -e '1')
i_dev=$(echo -e '2')
i_com=$(echo -e '3')
i_fun=$(echo -e '4')
i_sys=$(echo -e '5')
i_wrk=$(echo -e '6')
i_meh=$(echo -e '7')
i_far=$(echo -e '8')


# specific parameters
# desktop names
dskp_tag=('' $i_trm $i_web $i_dev $i_com $i_fun $i_sys $i_wrk $i_meh $i_far)

# colors
colors=(black red green yellow blue cyan magenta white black white)

# now playing format
mpc_format='[%title% ]|[%file%]'

# volume channel
alsa_channel='Master'

# define you own interfaces
net_wire='eth0'
net_wifi='wlan0'

# Only the time ? with seconds ? Maybe the current year...?
date_format="%H.%M"

# The default program to use, is -O <program> is not passed
default_output='bar'

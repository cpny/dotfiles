urxvtd &
compton &
setxkbmap pt &
start-pulseaudio-x11 & 
mopidy &
sxhkd &
nitrogen --restore &
xautolock -time 5 -locker "i3lock -c 170F0D" &

xset +fp /usr/share/fonts/local
xset fp rehash
xset +fp /home/cpn/.fonts
xset +fp /usr/share/fonts/misc
xset +fp /usr/share/fonts/artwiz-fonts
xset fp rehash
xrdb -merge /home/cpn/.Xresources &
xrdb -load ~/.Xresources &

exec bspwm

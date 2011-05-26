xset m 0/1 10
xset r rate 450 40
xset b off
xmodmap ~/.xmodmaprc
killall xbindkeys && xbindkeys &
#setxkbmap -layout "us,cz" -option "grp:alt_shift_toggle,grp_led:scroll"
urxvtd -q -f
#wicd-client &
urxvtc &
exec ck-launch-session awesome

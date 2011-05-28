#setxkbmap -layout "us,cz" -option "grp:alt_shift_toggle,grp_led:scroll"
#wicd-client &
urxvtd -q -f
(xrdb .Xdefaults.solarized; urxvtc)&
xset m 0/1 10&
xset r rate 450 40&
xset b off&
xmodmap ~/.xmodmaprc&
setxkbmap -option caps:super
killall xbindkeys && xbindkeys &
exec ck-launch-session awesome

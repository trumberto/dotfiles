#setxkbmap -layout "us,cz" -option "grp:alt_shift_toggle,grp_led:scroll"
wicd-client &
~/bin/set_monitors
urxvtd -q -f
(xrdb -merge .Xdefaults.solarized; urxvtc)
xset m 0/1 10
xset r rate 450 40
xset b off
xmodmap ~/.xmodmaprc&
syndaemon -d
setxkbmap -option caps:super
killall xbindkeys && xbindkeys &
wmname LG3D
clipit&
exec ck-launch-session awesome

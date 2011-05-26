#!/bin/bash

source ~/.rosdrc

VOLUME=`amixer get Master | grep Front.Left\: | sed -e s/"  Front Left: Playback [0-9]* \["// | sed -e s/"\%.*"//`
echo "VOLUME: [$VOLUME]"
osd_cat --offset=10 --indent=10 --color=$VOLUMECOLOR --font=$FONT --shadow=$VOLUMESHADOW --barmode=percentage --percentage=$VOLUME --delay=1 --age=1

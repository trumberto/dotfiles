#!/bin/bash

source ~/.rosdrc

TOTALSEC=`mocp --info | egrep "TotalSec\:" | sed 's/TotalSec\:\ //'`
CURRENTSEC=`mocp --info | egrep "CurrentSec\:" | sed 's/CurrentSec\:\ //'`

PERCENT=`echo "$CURRENTSEC*100/$TOTALSEC" | bc`

mocp --info | \
egrep "^Artist\:|^SongTitle\:|^Album\:" | \
osd_cat --offset=10 --indent=10 --color=$MOCPINFOCOLOR --font=$FONT --shadow=$MOCPINFOSHADOW &

osd_cat --offset=120 --indent=10 --color=$MOCPINFOCOLOR --shadow=$MOCPINFOSHADOW --barmode=percentage --percentage=$PERCENT

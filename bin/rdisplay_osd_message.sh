#!/bin/bash

source ~/.rosdrc

echo $1 | osd_cat --offset=10 --indent=10 --color=$MOCPINFOCOLOR --font=$FONT --shadow=$MOCPINFOSHADOW &

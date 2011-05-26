#/bin/bash

URL=`cat $1`
echo "U:$URL" > /tmp/test.txt
mocp --playit $URL
mocp --append $URL

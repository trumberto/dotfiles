#/bin/bash

URL=`grep "File" $1 | sed 's/File..//'`
mocp --playit $URL
mocp --append $URL

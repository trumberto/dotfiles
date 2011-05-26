#!/bin/sh

echo "naughty.notify({title = \"${1}\", text = \"${2}\", timeout = 10})" | /usr/bin/awesome-client -

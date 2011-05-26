#!/bin/sh
tempid=$$
echo get $1 -o /tmp/$tempid$1
echo shell vim /tmp/$tempid$1
echo put -E /tmp/$tempid$1 -o $1

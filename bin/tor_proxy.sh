#!/bin/sh

if [ "$1" -eq 1 ] 
then
    sudo ln -sf /etc/privoxy/config_tor_on /etc/privoxy/config
else
    sudo ln -sf /etc/privoxy/config_tor_off /etc/privoxy/config
fi
sudo /etc/init.d/privoxy restart

#!/bin/bash

rsync -avz -e ssh onyonus@onyon.us:public_html/onyon.net/ros/mp3 /home/rs
rsync -avz /home/rs/mp3 -e ssh onyonus@onyon.us:public_html/onyon.net/ros

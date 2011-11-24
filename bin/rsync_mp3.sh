#!/bin/bash

rsync -avz -e ssh rs@onyon.net:public_html/mp3 /home/rs
rsync -avz /home/rs/mp3 -e ssh rs@onyon.net:public_html

#!/bin/bash
python /home/pi/werkdir/sm/P1uitlezen.py > /home/pi/werkdir/sm/data/test.log 2>&1

/usr/local/bin/node /home/pi/werkdir/sm/parse.js

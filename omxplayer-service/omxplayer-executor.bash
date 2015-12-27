#!/bin/bash

readonly SECONDS_INTERVAL=10
readonly ENCODED_PASS="cGFzc3dkCg=="
readonly ENCODED_LOGIN="bG9naW4="
LOGIN=`echo "$ENCODED_LOGIN" | base64 --decode`
PASS=`echo "$ENCODED_PASS" | base64 --decode`

while true
do
    sleep $SECONDS_INTERVAL;
    omxplayer -b -r rtsp://$LOGIN:$PASS@192.168.1.2:554/12
done


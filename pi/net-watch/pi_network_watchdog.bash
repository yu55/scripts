#!/bin/bash

readonly GATEWAY="192.168.1.1"
readonly SECONDS_INTERVAL=300
readonly MAX_FAILS=3;

fail_counter=0;

logger "${0} started {GATEWAY=${GATEWAY}, SECONDS_INTERVAL=${SECONDS_INTERVAL}, MAX_FAILS=${MAX_FAILS}}";

while true
do
    sleep $SECONDS_INTERVAL;
    ping -c 1 $GATEWAY > /dev/null 2>&1;

    if [ $? = 0 ]; then
        fail_counter=0;
    else
        (( fail_counter++ ));
        logger "Cannot ping gateway (${GATEWAY}). Failure #${fail_counter}";
    fi;

    if (( fail_counter >= MAX_FAILS )); then
        logger "Cannot ping gateway (${GATEWAY}). I assume something is wrong with my network card. Going for reboot.";
        reboot;
    fi;
done


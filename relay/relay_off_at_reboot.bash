#!/bin/bash

LEVEL=`gpio -g read 11`;

gpio -g mode 11 out
gpio -g write 11 0

logger "Set relay to OFF at reboot";

OLD_LEVEL=$LEVEL
LEVEL=`gpio -g read 11`;
logger "OLD_LEVEL=$OLD_LEVEL, LEVEL=$LEVEL";
sqlite3 /var/local/relay-by-temp-db.sl3 "INSERT INTO pin11 VALUES(datetime(CURRENT_TIMESTAMP, 'localtime'), '$LEVEL');";
LAST_RESULT=$?;
if [ $LAST_RESULT -ne 0 ]; then
    logger "Error while saving relay level to database: $LAST_RESULT";
fi


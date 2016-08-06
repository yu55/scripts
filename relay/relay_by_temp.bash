#!/bin/bash

LINE=`grep 25_temperature /proc/multi-am2301`;
if [ $? -ne 0 ]; then
    echo "Problem with grep Temperature";
    exit $?;
fi
COLS=( $LINE );
T=${COLS[2]};

LEVEL=`gpio -g read 11`;

T_ON=29;
T_OFF=28;

CMP_RESULT=`echo $T'>='$T_ON | bc -l`;

if [ $CMP_RESULT -eq 1 ] && [[ "$LEVEL" == "0" ]]; then
    gpio -g mode 11 out
    gpio -g write 11 1

    logger "T_ON=$T_ON, T_OFF=$T_OFF, T=$T Set relay to ON";
fi

CMP_RESULT=`echo $T'<='$T_OFF | bc -l`;

if [ $CMP_RESULT -eq 1 ] && [[ "$LEVEL" == "1" ]]; then
    gpio -g mode 11 out
    gpio -g write 11 0

    logger "T_ON=$T_ON, T_OFF=$T_OFF, T=$T Set relay to OFF";
fi

OLD_LEVEL=$LEVEL
LEVEL=`gpio -g read 11`;
logger "T_ON=$T_ON, T_OFF=$T_OFF, T=$T, OLD_LEVEL=$OLD_LEVEL, LEVEL=$LEVEL";

for i in 1 2 3
do
    sqlite3 /var/local/relay-by-temp-db.sl3 "INSERT INTO pin11 VALUES(datetime(CURRENT_TIMESTAMP, 'localtime'), '$LEVEL');";
    LAST_RESULT=$?;
    if [ $LAST_RESULT -ne 0 ]; then
        logger "Error while saving relay level to database: $LAST_RESULT";
        sleep 2;
    else
        break;
    fi
done


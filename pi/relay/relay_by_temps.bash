#!/bin/bash

LINE=`grep 25_temperature /proc/multi-am2301`;
TempPin25='';
if [ $? -eq 0 ]; then
    COLS=( $LINE );
    TempPin25=${COLS[2]};
fi

LINE=`grep 25_timestamp /proc/multi-am2301`;
TstmpPin25='';
if [ $? -eq 0 ]; then
    COLS=( $LINE );
    TstmpPin25=${COLS[2]};
fi

# TODO: if older than 5 minutes TempPin25='';

TempAuriol=`sqlite3 /var/local/auriol-db.sl3 "SELECT amount FROM temperature WHERE created <= date('now','-5 minute') ORDER BY created DESC LIMIT 1;"`
LAST_RESULT=$?;
if [ $LAST_RESULT -ne 0 ]; then
    logger "$0: Error while reading TempAuriol from database: $LAST_RESULT";
fi

if [ "$TempPin25" = "" ] && [ "$TempAuriol" = "" ]; then
    echo "$0: Interrupting bacause of empty input temperatures: TempPin25=$TempPin25 and Tauriol=&Tauriol";
    exit;
fi

Tout="";
if [ "$TempPin25" = "" ]; then
    Tout=$TempAuriol;
elif [ "$TempAuriol" = "" ]; then
    Tout=$TempPin25;
else
    CMP_RESULT=`echo $TempPin25'<='$TempAuriol | bc -l`;
    if [ $CMP_RESULT -eq 1 ]; then
        Tout=$TempPin25;
    else
        Tout=$TempAuriol;
    fi
fi

LINE=`grep 24_temperature /proc/multi-am2301`;
if [ $? -ne 0 ]; then
    echo "$0: Problem with grep 24_temperature";
    exit $?;
fi
COLS=( $LINE );
Tin=${COLS[2]};

LEVEL=`gpio -g read 9`;

CMP_RESULT=`echo $Tin'>='$Tout+1 | bc -l`;

if [ $CMP_RESULT -eq 1 ] && [[ "$LEVEL" == "0" ]]; then
    gpio -g mode 9 out
    gpio -g write 9 1

    logger "$0: TempPin25=$TempPin25, TempAuriol=$TempAuriol, Tout=$Tout, Tin=$Tin, Set relay to ON";
fi

CMP_RESULT=`echo $Tin'<='$Tout | bc -l`;

if [ $CMP_RESULT -eq 1 ] && [[ "$LEVEL" == "1" ]]; then
    gpio -g mode 9 out
    gpio -g write 9 0

    logger "$0: TempPin25=$TempPin25, TempAuriol=$TempAuriol, Tout=$Tout, Tin=$Tin, Set relay to OFF";
fi

OLD_LEVEL=$LEVEL
LEVEL=`gpio -g read 9`;
logger "$0: TempPin25=$TempPin25, TempAuriol=$TempAuriol, Tout=$Tout, Tin=$Tin, OLD_LEVEL=$OLD_LEVEL, LEVEL=$LEVEL";

for i in 1 2 3
do
    sqlite3 /var/local/relay-by-temp-db.sl3 "INSERT INTO pin9 VALUES(datetime(CURRENT_TIMESTAMP, 'localtime'), '$LEVEL');";
    LAST_RESULT=$?;
    if [ $LAST_RESULT -ne 0 ]; then
        logger "$0: Error while saving relay level to database: $LAST_RESULT";
        sleep 2;
    else
        break;
    fi
done


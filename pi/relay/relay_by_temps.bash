#!/bin/bash

TempPin25='';
LINE=`grep 25_temperature /proc/multi-am2301`;
if [ $? -eq 0 ]; then
    COLS=( $LINE );
    TempPin25=${COLS[2]};
fi

TstmpPin25='';
LINE=`grep 25_timestamp /proc/multi-am2301`;
if [ $? -eq 0 ]; then
    COLS=( $LINE );
    TstmpPin25=${COLS[2]};
fi

CURRENT_TIMESTAMP=`date +%s`;
TempPin25Age=$((CURRENT_TIMESTAMP-TstmpPin25));
#logger "$0: CURRENT_TIMESTAMP=$CURRENT_TIMESTAMP, TstmpPin25=$TstmpPin25, TempPin25Age=$TempPin25Age";
if [ "$TempPin25Age" -gt 300 ]; then
    TempPin25="";
    logger "$0: TempPin25 too old - ignoring";
fi

TempAuriol=`sqlite3 /var/local/auriol-db.sl3 "SELECT amount FROM temperature WHERE created >= datetime('now','localtime','-5 minute') ORDER BY created DESC LIMIT 1;"`;
LAST_RESULT=$?;
if [ $LAST_RESULT -ne 0 ]; then
    logger "$0: Error while reading TempAuriol from database: $LAST_RESULT";
fi

if [ "$TempPin25" = "" ] && [ "$TempAuriol" = "" ]; then
    logger "$0: FATAL: Interrupting bacause of empty input temperatures: TempPin25=$TempPin25 and Tauriol=&Tauriol";
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

TinTstmp='';
LINE=`grep 24_timestamp /proc/multi-am2301`;
if [ $? -eq 0 ]; then
    COLS=( $LINE );
    TinTstmp=${COLS[2]};
fi

CURRENT_TIMESTAMP=`date +%s`;
TinAge=$((CURRENT_TIMESTAMP-TinTstmp));
#logger "$0: CURRENT_TIMESTAMP=$CURRENT_TIMESTAMP, TinTstmp=$TinTstmp, TinAge=$TinAge";
if [ "$TinAge" -gt 300 ]; then
    logger "$0: FATAL: Tin too old - exiting";
    exit;
fi

LEVEL=`gpio -g read 9`;

CMP_RESULT=`echo $Tin'>='$Tout+1 | bc -l`;

if [ $CMP_RESULT -eq 1 ] && [[ "$LEVEL" == "1" ]]; then
    gpio -g mode 9 out
    gpio -g write 9 0

    logger "$0: TempPin25=$TempPin25, TempAuriol=$TempAuriol, Tout=$Tout, Tin=$Tin, Set relay to ON";
fi

CMP_RESULT=`echo $Tin'<='$Tout | bc -l`;

if [ $CMP_RESULT -eq 1 ] && [[ "$LEVEL" == "0" ]]; then
    gpio -g mode 9 out
    gpio -g write 9 1

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


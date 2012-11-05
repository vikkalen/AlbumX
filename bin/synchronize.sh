#!/bin/bash

BIN_PATH=$0
BIN_DIR=${BIN_PATH%/*}

. $BIN_DIR/album.profile

PIDFILE=$BIN_DIR/synchronize.pid
if [ -f "$PIDFILE" ]
then
  pid=$(cat $PIDFILE)
  if [ -d "/proc/$pid" ]
  then
    echo "[$(date)] $0 is already running with pid $pid" >&2
    exit 1
  fi
fi

echo -n $$ > $PIDFILE

USR=michal
SRV=192.168.0.21
SRC=Pictures/
DST=/mnt/HD/HD_a2/Pictures/
DOFILE=$BIN_DIR/synchronize.done

ping -q -i 60 -c 180 $SRV >/dev/null
if [ $? -eq 0 ]
then
  echo "[$(date)] synchronizing..."
  rsync -av --delete $@ $USR@$SRV:$SRC $DST | egrep -e "\.[jJ][pP][gG]$" | egrep -ve "^deleting " >> $DOFILE
  echo "[$(date)] synchronized"
fi

rm $PIDFILE

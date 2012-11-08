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
SRC=Pictures/*
DST=/mnt/HD/HD_a2/Pictures/
DOFILE=$BIN_DIR/synchronize.done

while true
do
  while true; do netcat -z $SRV 22 >/dev/null && break; sleep 60; done
  rsync -av --delete $@ $USR@$SRV:$SRC $DST | egrep -e "\.[jJ][pP][eE]?[gG]$" >> $DOFILE
  sleep 3600
done
rm $PIDFILE

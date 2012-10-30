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
DOFILETMP=$BIN_DIR/synchronize.done.tmp

if [ -f "$DOFILETMP" ]
then
  mv "$DOFILETMP" "$DOFILE"
fi

ping -c1 $SRV >/dev/null
if [ $? -eq 0 ]
then
  echo "[$(date)] synchronizing..."
  touch "$DOFILETMP"
  res=$(rsync -av --delete $@ $USR@$SRV:$SRC $DST | egrep -e "\.[jJ][pP][gG]$" | egrep -ve "^deleting ")
  if [ -n "$res" ]
  then
    touch "$DOFILE"
  fi
  rm "$DOFILETMP"
  echo "[$(date)] synchronized"
else
  echo "[$(date)] cannot reach $SRV"
fi

rm $PIDFILE

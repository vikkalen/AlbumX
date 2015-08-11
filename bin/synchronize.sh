#!/bin/bash

trap 'kill -SIGTERM 0' EXIT

BIN_PATH=$(readlink -f "$0")
BIN_DIR=${BIN_PATH%/*}

. $BIN_DIR/album.profile

#PIDFILE=$BIN_DIR/synchronize.pid
#if [ -f "$PIDFILE" ]
#then
#  pid=$(cat $PIDFILE)
#  if [ -d "/proc/$pid" ]
#  then
#    echo "[$(date)] $0 is already running with pid $pid" >&2
#    exit 1
#  fi
#fi
#
#echo -n $$ > $PIDFILE

USR=$SYNC_SRC_USR
SRV=$SYNC_SRC_SRV
SRC=$SYNC_SRC
DST=$DOCUMENT_ROOT$ALBUM_DIR
DOFILE=$SYNC_FILE

while true
do
  while true; do nc -z $SRV 22 >/dev/null && break; sleep 60; done
  rsync -av --delete $@ $USR@$SRV:$SRC $DST/ | egrep -e "\.[jJ][pP][eE]?[gG]$" >> $DOFILE
  if [ $? -eq 0 ]
  then
    nc -q1 $SYNC_SRV $SYNC_PORT < $DOFILE
  fi
  sleep 3600
done
#rm $PIDFILE

#!/bin/bash

trap 'kill -SIGTERM 0' EXIT

BIN_PATH=$(readlink -f "$0")
BIN_DIR=${BIN_PATH%/*}

. $BIN_DIR/album.profile

#PIDFILE=$BIN_DIR/update-cache.pid
#if [ -f "$PIDFILE" ]
#then
#  pid=$(cat $PIDFILE)
#  if [ -d "/proc/$pid" ]
#  then
#    echo "[$(date)] $0 is already running with pid $pid" >&2
#    exit 1
#  else
#    rm $PIDFILE
#  fi
#fi
#
#echo -n $$ > $PIDFILE

function create_resized_dir {
  parent=$(dirname "$1")
  if [ ! -d "$parent" ]
  then
    create_resized_dir "$parent"
  fi
  mkdir -p -m 2775 "$1"
}

function update {
  src="$1"
  hash="$2"
  size="$3"

  cache="$CACHE_PATH/$size/$hash"
  dst="$DOCUMENT_ROOT$RESIZED_DIR/$size/${src#$SRC}"
  
  if [ "$src" -nt "$dst" ]
  then
    if [ -f "$dst" ]
    then
      rm "$dst"
      echo "[$(date)] remove $dst";
    fi
  fi

  if [ ! -f "$cache" ]
  then
    mkdir -p "${cache%/*}"
    base_url=${src#$DOCUMENT_ROOT}
    url="http://localhost:$PORT$base_url?size=$size"
    while true; do nc -z localhost $PORT >/dev/null && break; sleep 60; done
    wget -q -O "$cache" "$url";
    ret=$?
    if [ $ret -eq 0 ]
    then
      echo "[$(date)] get $url";
    else
      rm "$cache"
      echo "[$(date)] error $ret $url";
    fi
  elif [ ! -f "$dst" ]
  then
    create_resized_dir "${dst%/*}"
    cp "$cache" "$dst"
    touch "$dst" -r "$src"
    echo "[$(date)] cache $dst";
  fi
}

function update_file {

  cat "$1" | egrep -ve "^deleting " | while read src_file
  do
    src_file="$SRC${src_file#$SRC}"
    echo "[$(date)] $src_file" >&2;

    hash=$(md5sum "$src_file" | cut -d\  -f1)
    hash_file=${hash:0:1}/${hash:1:2}/${hash:3}

    update "$src_file" "$hash_file" "$SIZE_THUMB"
    update "$src_file" "$hash_file" "$SIZE_FULL"

  done
}

SRC=$DOCUMENT_ROOT$ALBUM_DIR/

DOFILE=$SYNC_FILE
DOFILETMP=$SYNC_FILE.tmp

if [ -f "$DOFILETMP" ]
then
  update_file "$DOFILETMP"
  DATE=$(date +"%Y%m%d%H%M")
  ARCHIVEFILE=$SYNC_FILE.$DATE.log
  cat "$DOFILETMP" >> $ARCHIVEFILE
  rm "$DOFILETMP"
fi
while true
do
  while [ -s "$DOFILE" ]
  do
    mv "$DOFILE" "$DOFILETMP"
    update_file "$DOFILETMP"
    DATE=$(date +"%Y%m%d%H%M")
    ARCHIVEFILE=$SYNC_FILE.$DATE.log
    cat "$DOFILETMP" >> $ARCHIVEFILE
    rm "$DOFILETMP"
  done
  nc -l -p $SYNC_PORT > /dev/null
done

#rm $PIDFILE

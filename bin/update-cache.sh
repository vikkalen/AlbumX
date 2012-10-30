#!/bin/bash

BIN_PATH=$0
BIN_DIR=${BIN_PATH%/*}

. $BIN_DIR/album.profile

PIDFILE=$BIN_DIR/update-cache.pid
if [ -f "$PIDFILE" ]
then
  pid=$(cat $PIDFILE)
  if [ -d "/proc/$pid" ]
  then
    echo "[$(date)] $0 is already running with pid $pid" >&2
    exit 1
  else
    rm $PIDFLIE
  fi
fi

DOFILE=$BIN_DIR/synchronize.done
if [ ! -f "$DOFILE" ]
  echo "[$(date)] nothing to do" >&2
  exit 1
fi

echo -n $$ > $PIDFILE

SRC=$APP_HOME/$ALBUM_DIR/

function remove {
  src=$1
  dst=$2
  if [ "$src" -nt "$dst" ]
  then
    if [ -f "$dst" ]
    then
      rm "$dst"
      echo "[$(date)] remove $dst";
    fi
  fi
}

function update {
  src="$1"
  hash="$2"
  size="$3"

  cache="$APP_HOME/$CACHE_DIR/$size/$hash"
  dst="$APP_HOME/$RESIZED_DIR/$size/${src#$SRC}"

  remove "$src" "$dst"

  if [ ! -f "$cache" ]
  then
    mkdir -p "${cache%/*}"
    base_url=${src#$APP_HOME}
    url="$ALBUM_SRV$base_url?size=$size"
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
    mkdir -p "${dst%/*}"
    cp "$cache" "$dst"
    touch "$dst" -r "$src"
    echo "[$(date)] cache $dst";
  fi
}

find -L $SRC -type f -name "*.[jJ][pP][gG]" | while read src_file
do
  echo "[$(date)] $src_file" >&2;

  hash=$(md5sum "$src_file" | cut -d\  -f1)
  hash_file=${hash:0:1}/${hash:1:2}/${hash:3}

  update "$src_file" "$hash_file" "$SIZE_THUMB"
  update "$src_file" "$hash_file" "$SIZE_FULL"

done

rm $DOFILE
rm $PIDFILE

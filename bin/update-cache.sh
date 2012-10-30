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
DST_THUMB=$APP_HOME/$RESIZED_DIR/$SIZE_THUMB/
DST_FULL=$APP_HOME/$RESIZED_DIR/$SIZE_FULL/

CACHE_THUMB=$APP_HOME/$CACHE_DIR/$SIZE_THUMB/
CACHE_FULL=$APP_HOME/$CACHE_DIR/$SIZE_FULL/

function update {
  src=$1
  dst=$2
  cache=$3
  url=$4
  if [ ! -f "$cache" ]
  then
    mkdir -p "${cache%/*}"
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


find -L $SRC -type f -name "*.[jJ][pP][gG]" | while read src_file
do
  echo "[$(date)] $src_file" >&2;
  base_path=${src_file#$SRC}
  dst_file_thumb="$DST_THUMB$base_path"
  dst_file_full="$DST_FULL$base_path"

  base_url=${src_file#$APP_HOME}
  url_thumb="${base_url}?size=$SIZE_THUMB"
  url_full="${base_url}?size=$SIZE_FULL"

  hash=$(md5sum "$src_file" | cut -d\  -f1)
  hash_dir=${hash:0:2}/${hash:2:2}
  hash_file=${hash:4}

  cache_file_thumb="$CACHE_THUMB$hash_dir/$hash_file"
  cache_file_full="$CACHE_FULL$hash_dir/$hash_file"

  remove "$src_file" "$dst_file_thumb"
  update "$src_file" "$dst_file_thumb" "$cache_file_thumb" "$ALBUM_SRV$url_thumb"

  remove "$src_file" "$dst_file_full"
  update "$src_file" "$dst_file_full" "$cache_file_full" "$ALBUM_SRV$url_full"

done

rm $DOFILE
rm $PIDFILE

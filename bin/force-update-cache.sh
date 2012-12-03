#!/bin/bash

BIN_PATH=$(readlink -f "$0")
BIN_DIR=${BIN_PATH%/*}

. $BIN_DIR/album.profile

DOFILE=$SYNC_FILE
SRC=$DOCUMENT_ROOT$ALBUM_DIR/

find -L $SRC -type f -regex ".*\.[jJ][pP][eE]?[gG]" -fprintf "$DOFILE" "%p\n"
nc -q1 $SYNC_SRV $SYNC_PORT < "$DOFILE"

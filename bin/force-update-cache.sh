#!/bin/bash

BIN_PATH=$0
BIN_DIR=${BIN_PATH%/*}

. $BIN_DIR/album.profile

DOFILE=$BIN_DIR/synchronize.done
SRC=$APP_HOME/$ALBUM_DIR/

find -L $SRC -type f -regex ".*\.[jJ][pP][eE]?[gG]" -fprintf "$DOFILE" "%p\n"

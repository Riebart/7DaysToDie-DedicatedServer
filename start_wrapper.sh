#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage: start_wrapper.sh <name of server_config in data directory>"
    exit 1
fi

HOME_DIR="$(dirname $(dirname "`realpath "$0"`"))"
SCRIPT_DIR="$HOME_DIR/scripts"
DATA_DIR="$HOME_DIR/data"
SERVER_DIR="$HOME_DIR/server_install"

echo "HOME_DIR $HOME_DIR"
echo "SCRIPT_DIR $SCRIPT_DIR"
echo "DATA_DIR $DATA_DIR"
echo "SERVER_DIR $SERVER_DIR"

bash -x $SCRIPT_DIR/update_dedicated.sh "$SERVER_DIR" "alpha21.2"

SERVERDIR="$SERVER_DIR" \
    bash -x $SCRIPT_DIR/startserver.sh \
    "-configfile=$DATA_DIR/$1"

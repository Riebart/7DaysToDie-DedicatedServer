#!/bin/bash

SERVER_DIR="$1"
BETA_TARGET="$2"

if [ "$SERVER_DIR" == "" ]
then
    echo "Usage: update_dedicated.sh <server_install_dir> [beta_target]"
    exit 1
fi

if [ "$BETA_TARGET" == "" ]
then
    steamcmd \
        +force_install_dir "$SERVER_DIR" \
        +login anonymous \
        +app_update 294420 validate \
        +quit
else
    steamcmd \
        +force_install_dir "$SERVER_DIR" \
        +login anonymous \
        +app_update 294420 validate \
        -beta "$BETA_TARGET" +quit
fi

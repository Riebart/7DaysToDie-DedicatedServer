#!/bin/bash

HOME_DIR="$(dirname $(dirname "`realpath "$0"`"))"
SCRIPT_DIR="$HOME_DIR/scripts"
DATA_DIR="$HOME_DIR/data"
SERVER_DIR="$HOME_DIR/server_install"

echo "HOME_DIR $HOME_DIR"
echo "SCRIPT_DIR $SCRIPT_DIR"
echo "DATA_DIR $DATA_DIR"
echo "SERVER_DIR $SERVER_DIR"

# Tell the server to explicitly save the world to disk, then wait a few seconds
(
    echo "sa"
    sleep 2
    echo "exit"
    sleep 1
) | nc -vnw1 127.0.0.1 27881 && sleep 10

# Pack up ZFS restoration streams for the saves and scripts
if [ "$SKIP_ZFS" == "" ]
then
    DATA_ZFS=$(mount | grep "$DATA_DIR" | cut -d ' ' -f1)
    SCRIPT_ZFS=$(mount | grep "$SCRIPT_DIR" | cut -d ' ' -f1)

    echo -e "data $DATA_ZFS\nscript $SCRIPT_ZFS" | while read name zfs_ds
    do
        zfs_snap=$(zfs list -Ht snapshot "$zfs_ds" | tail -n1 | cut -f1)
        zfs send -R -v "$zfs_snap"| zstd -9c - | \
            rclone rcat \
            od:"DedicatedServers/7 Days to Die - ${name}.zfs.zstd"
    done
fi

# Also ship the save worlds directly as current state
rclone copy "$DATA_DIR" od:"DedicatedServers/7 Days to Die/Data"
rclone copy "$SCRIPT_DIR" od:"DedicatedServers/7 Days to Die/Scripts"

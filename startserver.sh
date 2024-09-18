#!/bin/sh

HOME_DIR="$(dirname $(dirname "`realpath "$0"`"))"
SCRIPT_DIR="$HOME_DIR/scripts"
DATA_DIR="$HOME_DIR/data"
SERVER_DIR="$HOME_DIR/server_install"

echo "HOME_DIR $HOME_DIR"
echo "SCRIPT_DIR $SCRIPT_DIR"
echo "DATA_DIR $DATA_DIR"
echo "SERVER_DIR $SERVER_DIR"

if [ "$SERVERDIR" == "" ]
then
    SERVERDIR=`dirname "$0"`
fi

cd "$SERVERDIR"
PARAMS=$@

CONFIGFILE=
while test $# -gt 0
do
	if [ `echo $1 | cut -c 1-12` = "-configfile=" ]; then
		CONFIGFILE=`echo $1 | cut -c 13-`
	fi
	shift
done

if [ "$CONFIGFILE" = "" ]; then
	echo "No config file specified. Call this script like this:"
	echo "  ./startserver.sh -configfile=serverconfig.xml"
	exit 1
else
	if [ -f "$CONFIGFILE" ]; then
		echo Using config file: $CONFIGFILE
	else
		echo "Specified config file $CONFIGFILE does not exist."
		exit 1
	fi
fi

export LD_LIBRARY_PATH=.
#export MALLOC_CHECK_=0

screen -S "7DaysToDieServer" -d -m ./7DaysToDieServer.x86_64 \
    -logfile "$DATA_DIR/server_logs/output_log__`date +%Y-%m-%d__%H-%M-%S`.txt" \
    -quit -batchmode -nographics -dedicated \
    $PARAMS

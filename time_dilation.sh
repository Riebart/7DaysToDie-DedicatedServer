#!/bin/bash

telnet_port=27881
lastlp="0"
maxtickrate="6" # This is normal speed

function telnet_write {
  echo "$1"
  sleep 0.75
  echo "exit"
  sleep 0.75
}

# In case we're being launched and the server isn't up yet, just loop until it is
failed_count=0
while true
do
    (echo "lp"; sleep 10; echo "exit"; sleep 1) | \
        nc -vnw1 127.0.0.1 27881 | \
        grep -c "Total of [0-9]* in the game"
    if [ $? -eq 0 ]
    then
        if [ $failed_count -gt 0 ]
        then
            sleep 60
        fi

        break
    else
        failed_count=$[failed_count+1]
        sleep 10
    fi
done

telnet_write "ggs" | nc -vn 127.0.0.1 $telnet_port | grep "GameStat.TimeOfDayIncPerSec"
telnet_write "lp" | nc -vn 127.0.0.1 $telnet_port | grep "Total of"

while [ true ]
do
  # Get the current number of players
  lp=$(telnet_write "lp" | nc -w1 127.0.0.1 $telnet_port | sed -n 's/Total of \([0-9]*\) in the game/\1/p' | tr -dc '0-9')

  # Only poke the telnet endpoint if the number of players has changed.
  if [ "$lp" != "$lastlp" ]
  then
    # If time is stopped, then when someone joins they just sit at midnight on day 0
    # so it can't sit at zero, needs to sit at least at 1.
    if [ $lp -eq 0 ]
    then
        tickrate=$maxtickrate
    # If there's onyl one person, then bump it to 1 briefly, then stop time.
    # A single person won't cause time to move.
    elif [ $lp -lt 2 ]
    then
      telnet_write "sgs TimeOfDayIncPerSec 1" | tee /dev/stderr | nc -w1 127.0.0.1 $telnet_port > /dev/null 2>&1
      sleep 10
      tickrate=0
    elif [ $lp -lt 4 ]
    then
      # 3 or fewer players, tickrate scales linearly
      tickrate=$lp
    else
      # 4 or more players, tickrate hits "Normal" at 5 players.
      tickrate=$[lp+1]
    fi

    # Clamp it to the normal speed.
    if [ $tickrate -gt $maxtickrate ]
    then
        tickrate=$maxtickrate
    fi

    echo "Player count changed from $lastlp to $lp"
    echo "Current game tick rate: $(telnet_write 'ggs' | nc -w1 127.0.0.1 $telnet_port | grep GameStat.TimeOfDayIncPerSec)"
    echo "New game tick rate: $tickrate"
    telnet_write "sgs TimeOfDayIncPerSec $tickrate" | tee /dev/stderr | nc -w1 127.0.0.1 $telnet_port > /dev/null 2>&1
    echo "New effective game tick rate: $(telnet_write 'ggs' | nc -w1 127.0.0.1 $telnet_port | grep GameStat.TimeOfDayIncPerSec)"
  else
    echo "No change in player count on the server"
  fi

  lastlp="$lp"

  sleep 60
done | while read line
do
  echo "`date | tr -d '\n'` $line"
done

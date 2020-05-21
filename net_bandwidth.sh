#!/bin/bash

transmit_prev=0
receive_prev=0

unit=('B' 'K' 'M' 'G')

getAdaptiveUnit()
{
    i=0
    speed=$1
    while [ $speed -ge 1024 ]
    do
        speed=$(($speed/1024))
        i=$(($i+1))
        echo 
    done
    echo $speed''${unit[$i]}
}

while true
do
    cont=$(cat /proc/net/dev | grep $1)
    transmit=$(echo $cont | awk '{print $10}')
    receive=$(echo $cont | awk '{print $2}')
    speed_transmit=$(($transmit-$transmit_prev))
    speed_receive=$(($receive-$receive_prev))

    adaptive_transmit=$(getAdaptiveUnit $speed_transmit)
    adaptive_receive=$(getAdaptiveUnit $speed_receive)
    echo 'network bandwidth:'
    echo -e '    transmit: '$speed_transmit'('$adaptive_transmit')    receive:'$speed_receive'('$adaptive_receive')'
    transmit_prev=$transmit
    receive_prev=$receive
    sleep 1
done
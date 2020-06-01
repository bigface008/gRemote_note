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


echo 'gRemote log:'

while true
do
    timestamp=`date '+%Y-%m-%d %H:%M:%S:%N'`
    echo "timestamp $timestamp"

    # server_info=$(ps aux | grep 'cgl-render' | grep -v grep)
    # client_info=$(ps aux | grep 'cgl-capture' | grep -v grep)
    server_cpu_usage=$(ps aux | grep 'cgl-render' | grep -v grep | awk '{sum += $3}END{print sum}')
    client_cpu_usage=$(ps aux | grep 'cgl-capture' | grep -v grep | awk '{sum += $3}END{print sum}')
    server_mem_usage=$(ps aux | grep 'cgl-render' | grep -v grep | awk '{sum += $6}END{print sum}')
    client_mem_usage=$(ps aux | grep 'cgl-capture' | grep -v grep | awk '{sum += $6}END{print sum}')
    # server_cpu_usage=$(echo $server_info | awk '{sum += $3}END{print sum}')
    # client_cpu_usage=$(echo $client_info | awk '{sum += $3}END{print sum}')
    # server_mem_usage=$(echo $server_info | awk '{sum += $6}END{print sum}')
    # client_mem_usage=$(echo $client_info | awk '{sum += $6}END{print sum}')
    echo "    cpu: client $client_cpu_usage%; server $server_cpu_usage%;"
    echo "    mem: client ${client_mem_usage}KB; server ${server_mem_usage}KB;"
    # echo "    gpu: client %; server %;"
    # echo "    gpu mem: client %; server %;"
    # echo 'server_cpu_usage:'$server_cpu_usage
    # echo 'client_cpu_usage:'$client_cpu_usage

    cont=$(cat /proc/net/dev | grep $1)
    transmit=$(echo $cont | awk '{print $10}')
    receive=$(echo $cont | awk '{print $2}')
    speed_transmit=$(($transmit-$transmit_prev))
    speed_receive=$(($receive-$receive_prev))

    adaptive_transmit=$(getAdaptiveUnit $speed_transmit)
    adaptive_receive=$(getAdaptiveUnit $speed_receive)
    # echo 'network bandwidth:'
    echo -e '    transmit: '$speed_transmit'('$adaptive_transmit')    receive:'$speed_receive'('$adaptive_receive')'
    transmit_prev=$transmit
    receive_prev=$receive

    sleep 1
done

#!/bin/bash

echo 'cgl-render (server) cpu usage:'

while true
do
    usage_cgl=$(ps aux | grep 'cgl-render' |awk '{sum += $3}END{print sum}')
    echo 'cgl:'$usage_cgl
    sleep 1
done

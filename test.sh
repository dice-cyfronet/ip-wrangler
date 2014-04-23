#!/bin/bash

set -x

export __IP="192.168.122.94"
export __PORT=8400

for __port in `seq 1024 1028`; do
    curl -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}/tcp
    curl -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}/udp
done

read

for __port in `seq 2049 2053`; do
    curl -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}
done

read

for __id in `seq 1 3`; do
    curl -X POST --data "" http://${__IP}:${__PORT}/nat/ip/127.0.0.1
done

read

curl http://${__IP}:${__PORT}/nat/port
curl http://${__IP}:${__PORT}/nat/port/127.0.0.1

curl http://${__IP}:${__PORT}/nat/ip
curl http://${__IP}:${__PORT}/nat/ip/127.0.0.1

read

for __port in `seq 1024 1026`; do
    curl -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}/tcp
    curl -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}/udp
done

read

for __port in `seq 1027 1028`; do
    curl -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}
done

read

curl -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1

for __id in `seq 1 2`; do
    curl -X DELETE --data "" http://${__IP}:${__PORT}/nat/ip/127.0.0.1/10.0.0.${__id}
done

read

curl -X DELETE --data "" http://${__IP}:${__PORT}/nat/ip/127.0.0.1

read

curl http://${__IP}:${__PORT}/

read

for __port in `seq 1024 1028`; do
    curl -X POST --data "[{\"port\": ${__port}, \"proto\": \"tcp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.1
    curl -X POST --data "[{\"port\": ${__port}, \"proto\": \"udp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.1
done

read

for __port in `seq 2049 2053`; do
    curl -X POST --data "[{\"port\": ${__port}, \"proto\": \"tcp\"}, {\"port\": ${__port}, \"proto\": \"udp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.1
done

read

curl http://${__IP}:${__PORT}/dnat
curl http://${__IP}:${__PORT}/dnat/127.0.0.1

read

for __port in `seq 1024 1026`; do
    curl -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.1/${__port}/tcp
    curl -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.1/${__port}/udp
done

read

for __port in `seq 1027 1028`; do
    curl -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.1/${__port}
done

read

curl -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1
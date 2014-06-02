#!/bin/bash

set -x

export __IP="192.168.100.141"
export __PORT=8400

for __port in `seq 1024 1028`; do
    curl -u test:test -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}/tcp
    curl -u test:test -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}/udp
done

read

for __port in `seq 2049 2053`; do
    curl -u test:test -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}
done

read

for __id in `seq 1 3`; do
    curl -u test:test -X POST --data "" http://${__IP}:${__PORT}/nat/ip/127.0.0.1
done

read

curl -u test:test http://${__IP}:${__PORT}/nat/port
curl -u test:test http://${__IP}:${__PORT}/nat/port/127.0.0.1

curl -u test:test http://${__IP}:${__PORT}/nat/ip
curl -u test:test http://${__IP}:${__PORT}/nat/ip/127.0.0.1

read

for __port in `seq 1024 1026`; do
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}/tcp
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}/udp
done

read

for __port in `seq 1027 1028`; do
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}
done

read

curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1

for __id in `seq 1 2`; do
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/ip/127.0.0.1/10.0.0.${__id}
done

read

curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/ip/127.0.0.1

read

curl -u test:test http://${__IP}:${__PORT}/

read

for __port in `seq 1024 1028`; do
    curl -u test:test -X POST --data "[{\"port\": ${__port}, \"proto\": \"tcp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.1
    curl -u test:test -X POST --data "[{\"port\": ${__port}, \"proto\": \"udp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.1
done

read

for __port in `seq 2049 2053`; do
    curl -u test:test -X POST --data "[{\"port\": ${__port}, \"proto\": \"tcp\"}, {\"port\": ${__port}, \"proto\": \"udp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.1
done

read

curl -u test:test http://${__IP}:${__PORT}/dnat
curl -u test:test http://${__IP}:${__PORT}/dnat/127.0.0.1

read

for __port in `seq 1024 1026`; do
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.1/${__port}/tcp
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.1/${__port}/udp
done

read

for __port in `seq 1027 1028`; do
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.1/${__port}
done

read

curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1

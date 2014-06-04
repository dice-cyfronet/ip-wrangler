#!/bin/bash

#set -x

export __IP="127.0.0.1"
export __PORT=8400

for __port in `seq 10000 10010`; do
    curl -u test:test -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}/tcp
    echo ""
    curl -u test:test -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}/udp
    echo ""
done

read

for __port in `seq 10005 10015`; do
    curl -u test:test -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}
    echo ""
done

read

for __id in `seq 1 3`; do
    curl -u test:test -X POST --data "" http://${__IP}:${__PORT}/nat/ip/127.0.0.1
    echo ""
done

read

curl -u test:test http://${__IP}:${__PORT}/nat/port
echo ""
curl -u test:test http://${__IP}:${__PORT}/nat/port/127.0.0.1
echo ""

curl -u test:test http://${__IP}:${__PORT}/nat/ip
echo ""
curl -u test:test http://${__IP}:${__PORT}/nat/ip/127.0.0.1
echo ""

read

for __port in `seq 10000 10010`; do
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}/tcp
    echo ""
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}/udp
    echo ""
done

read

for __port in `seq 10005 10015`; do
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1/${__port}
    echo ""
done

read

curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1
echo ""

for __id in `seq 1 2`; do
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/ip/127.0.0.1/10.0.0.${__id}
    echo ""
done

read

curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/ip/127.0.0.3
echo ""

read

curl -u test:test http://${__IP}:${__PORT}/
echo ""

read

for __port in `seq 10000 10010`; do
    curl -u test:test -X POST --data "[{\"port\": ${__port}, \"proto\": \"tcp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.1
    echo ""
    curl -u test:test -X POST --data "[{\"port\": ${__port}, \"proto\": \"udp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.1
    echo ""
done

read

for __port in `seq 10005 10015`; do
    curl -u test:test -X POST --data "[{\"port\": ${__port}, \"proto\": \"tcp\"}, {\"port\": ${__port}, \"proto\": \"udp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.1
    echo ""
done

read

curl -u test:test http://${__IP}:${__PORT}/dnat
echo ""
curl -u test:test http://${__IP}:${__PORT}/dnat/127.0.0.1
echo ""

read

for __port in `seq 10000 10010`; do
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.1/${__port}/tcp
    echo ""
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.1/${__port}/udp
    echo ""
done

read

for __port in `seq 10005 10015`; do
    curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.1/${__port}
    echo ""
done

read

curl -u test:test -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.1
echo ""

#!/bin/bash

#set -x

export __IP="127.0.0.1"
#export __IP="***REMOVED***"
export __PORT=8400
#export __PORT=55000

export __USER=cyfronet
export __PASS=***REMOVED***

for __ip in `seq 1 3`; do
    for __port in `seq 1000 1010`; do
        curl -u ${__USER}:${__PASS} -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}/${__ip}${__port}/tcp
        echo ""
        curl -u ${__USER}:${__PASS} -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}/${__ip}${__port}/udp
        echo ""
    done
done

read

for __ip in `seq 1 3`; do
    for __port in `seq 1005 1015`; do
        curl -u ${__USER}:${__PASS} -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}/${__ip}${__port}
        echo ""
    done
done

read

for __ip in `seq 1 3`; do
    curl -u ${__USER}:${__PASS} -X POST --data "" http://${__IP}:${__PORT}/nat/ip/127.0.1.${__ip}
    echo ""
done

read

curl -u ${__USER}:${__PASS} http://${__IP}:${__PORT}/nat/port
echo ""

for __ip in `seq 1 3`; do
    curl -u ${__USER}:${__PASS} http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}
    echo ""
done

curl -u ${__USER}:${__PASS} http://${__IP}:${__PORT}/nat/ip
echo ""

read

for __ip in `seq 1 3`; do
    for __port in `seq 1000 1010`; do
        curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}/${__ip}${__port}/tcp
        echo ""
        curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}/${__ip}${__port}/udp
        echo ""
    done
done

read

for __ip in `seq 1 3`; do
    for __port in `seq 1005 1015`; do
        curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}/${__ip}${__port}
        echo ""
    done
done

read

for __ip in `seq 1 3`; do
    curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}
    echo ""
done

for __id in `seq 1 2`; do
    curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/ip/127.0.1.${__id}
    echo ""
done

read

curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/ip/127.0.1.3
echo ""

read

curl -u ${__USER}:${__PASS} http://${__IP}:${__PORT}/
echo ""

read

for __ip in `seq 1 3`; do
    for __port in `seq 1000 1010`; do
        curl -u ${__USER}:${__PASS} -X POST --data "[{\"port\": ${__ip}${__port}, \"proto\": \"tcp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}
        echo ""
        curl -u ${__USER}:${__PASS} -X POST --data "[{\"port\": ${__ip}${__port}, \"proto\": \"udp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}
        echo ""
    done
done

read

for __ip in `seq 1 3`; do
    for __port in `seq 1005 1015`; do
        curl -u ${__USER}:${__PASS} -X POST --data "[{\"port\": ${__ip}${__port}, \"proto\": \"tcp\"}, {\"port\": ${__ip}${__port}, \"proto\": \"udp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}
        echo ""
    done
done

read

curl -u ${__USER}:${__PASS} http://${__IP}:${__PORT}/dnat
echo ""

for __ip in `seq 1 3`; do
    curl -u ${__USER}:${__PASS} http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}
    echo ""
done

read

for __ip in `seq 1 3`; do
    for __port in `seq 1000 1010`; do
        curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}/${__ip}${__port}/tcp
        echo ""
        curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}/${__ip}${__port}/udp
        echo ""
    done
done

read

for __ip in `seq 1 3`; do
    for __port in `seq 1005 1015`; do
        curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}/${__ip}${__port}
        echo ""
    done
done

read

for __ip in `seq 1 3`; do
    curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}
    echo ""
done

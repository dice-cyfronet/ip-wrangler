#!/bin/bash

# It provides execution tests for Ip-Wrangler.

echo "NO WARRANTY. YOU ARE USING THIS ON YOUR OWN RISK!"

#set -x

export __IP="127.0.0.1"
export __PORT=8400

export __USER=username
export __PASS=password

if (( "$#" >= "1" )); then
    export __IP=$1
fi

if (( "$#" >= "2" )); then
    export __PORT=$2
fi

if (( "$#" >= "3" )); then
    export __USER=$3
fi

if (( "$#" >= "4" )); then
    export __PASS=$4
fi

echo "IP: ${__IP} Port:${__PORT} User:${__USER} Pass:${__PASS}"

echo "You can interrupt it now by (ctrl)+(c).."
read

echo "Press enter to continue.."
read

echo "Add tcp/udp port NAT rules using new API"
for __ip in `seq 1 3`; do
    for __port in `seq 1000 1010`; do
        curl -u ${__USER}:${__PASS} -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}/${__ip}${__port}/tcp
        echo ""
        curl -u ${__USER}:${__PASS} -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}/${__ip}${__port}/udp
        echo ""
    done
done

echo "Press enter to continue.."
read

echo "Add port NAT rules using new API"
for __ip in `seq 1 3`; do
    for __port in `seq 1005 1015`; do
        curl -u ${__USER}:${__PASS} -X POST --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}/${__ip}${__port}
        echo ""
    done
done

echo "Press enter to continue.."
read

echo "Add IP NAT rules using new API"
for __ip in `seq 1 3`; do
    curl -u ${__USER}:${__PASS} -X POST --data "" http://${__IP}:${__PORT}/nat/ip/127.0.1.${__ip}
    echo ""
done

echo "Press enter to continue.."
read

echo "Print all port NAT rules"
curl -u ${__USER}:${__PASS} http://${__IP}:${__PORT}/nat/port
echo ""

echo "Print all port NAT rules for specific IP"
for __ip in `seq 1 3`; do
    curl -u ${__USER}:${__PASS} http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}
    echo ""
done

echo "Print all IP rules"
curl -u ${__USER}:${__PASS} http://${__IP}:${__PORT}/nat/ip
echo ""

echo "Press enter to continue.."
read

echo "Remove tcp/udp port NAT rules using new API"
for __ip in `seq 1 3`; do
    for __port in `seq 1000 1010`; do
        curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}/${__ip}${__port}/tcp
        echo ""
        curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}/${__ip}${__port}/udp
        echo ""
    done
done

echo "Press enter to continue.."
read

echo "Remove port NAT rules using new API"
for __ip in `seq 1 3`; do
    for __port in `seq 1005 1015`; do
        curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}/${__ip}${__port}
        echo ""
    done
done

echo "Press enter to continue.."
read

echo "Remove port NAT rules per IP using new API"
for __ip in `seq 1 3`; do
    curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}
    echo ""
done

echo "Remove IP NAT rules per IP using new API"
for __id in `seq 1 2`; do
    curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/ip/127.0.1.${__id}
    echo ""
done

echo "Press enter to continue.."
read

echo "Remove IP NAT rules per IP using new API (again)"
curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/ip/127.0.1.3
echo ""

echo "Press enter to continue.."
read

echo "Echo test"
curl -u ${__USER}:${__PASS} http://${__IP}:${__PORT}/
echo ""

echo "Press enter to continue.."
read

echo "Add tcp/udp port NAT rules using old API"
for __ip in `seq 1 3`; do
    for __port in `seq 1000 1010`; do
        curl -u ${__USER}:${__PASS} -X POST --data "[{\"port\": ${__ip}${__port}, \"proto\": \"tcp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}
        echo ""
        curl -u ${__USER}:${__PASS} -X POST --data "[{\"port\": ${__ip}${__port}, \"proto\": \"udp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}
        echo ""
    done
done

echo "Press enter to continue.."
read

echo "Add tcp/udp port NAT rules using old API"
for __ip in `seq 1 3`; do
    for __port in `seq 1005 1015`; do
        curl -u ${__USER}:${__PASS} -X POST --data "[{\"port\": ${__ip}${__port}, \"proto\": \"tcp\"}, {\"port\": ${__ip}${__port}, \"proto\": \"udp\"}]" http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}
        echo ""
    done
done

echo "Press enter to continue.."
read

echo "Print all port NAT rules"
curl -u ${__USER}:${__PASS} http://${__IP}:${__PORT}/dnat
echo ""

echo "Print all port NAT rules for specific IP"
for __ip in `seq 1 3`; do
    curl -u ${__USER}:${__PASS} http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}
    echo ""
done

echo "Press enter to continue.."
read

echo "Remove tcp/udp port NAT rules using old API"
for __ip in `seq 1 3`; do
    for __port in `seq 1000 1010`; do
        curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}/${__ip}${__port}/tcp
        echo ""
        curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}/${__ip}${__port}/udp
        echo ""
    done
done

echo "Press enter to continue.."
read

echo "Remove port NAT rules using old API"
for __ip in `seq 1 3`; do
    for __port in `seq 1005 1015`; do
        curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/dnat/127.0.0.${__ip}/${__ip}${__port}
        echo ""
    done
done

echo "Press enter to continue.."
read

echo "Remove port NAT rules using old API (again)"
for __ip in `seq 1 3`; do
    curl -u ${__USER}:${__PASS} -X DELETE --data "" http://${__IP}:${__PORT}/nat/port/127.0.0.${__ip}
    echo ""
done

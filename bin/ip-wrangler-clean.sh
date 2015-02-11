#!/bin/bash

if [ -z "$1" ]
then
    echo "Usage: $(basename $0) <iptables_chain_name|maybe:IPT_WR>"
    exit 1
fi

iptables_chain_name=$1

set -x

sudo /sbin/iptables -t nat --delete PREROUTING --jump ${iptables_chain_name}_PRE
sudo /sbin/iptables -t nat --delete POSTROUTING --jump ${iptables_chain_name}_POST
sudo /sbin/iptables -t nat --flush ${iptables_chain_name}_PRE
sudo /sbin/iptables -t nat --flush ${iptables_chain_name}_POST
sudo /sbin/iptables -t nat --delete-chain ${iptables_chain_name}_PRE
sudo /sbin/iptables -t nat --delete-chain ${iptables_chain_name}_POST

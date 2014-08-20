#!/bin/bash

export __dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -x

sudo /sbin/iptables -t nat --delete PREROUTING --jump IPT_WR_PRE
sudo /sbin/iptables -t nat --delete POSTROUTING --jump IPT_WR_POST
sudo /sbin/iptables -t nat --flush IPT_WR_PRE
sudo /sbin/iptables -t nat --flush IPT_WR_POST
sudo /sbin/iptables -t nat --delete-chain IPT_WR_PRE
sudo /sbin/iptables -t nat --delete-chain IPT_WR_POST

exit 0

#!/bin/bash

export __dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -x

${__dir}/stop.sh

/sbin/iptables -w -t nat --delete PREROUTING --jump IPT_WR_PRE
/sbin/iptables -w -t nat --delete POSTROUTING --jump IPT_WR_POST
/sbin/iptables -w -t nat --flush IPT_WR_PRE
/sbin/iptables -w -t nat --flush IPT_WR_POST
/sbin/iptables -w -t nat --delete-chain IPT_WR_PRE
/sbin/iptables -w -t nat --delete-chain IPT_WR_POST

rm -f ${__dir}/src/log/*.log
rm -f ${__dir}/src/config.yml
rm -f ${__dir}/src/ipt.db
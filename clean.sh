#!/bin/bash

export __dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -x

/sbin/iptables curl -u test:test-t nat --delete PREROUTING --jump IPT_WR_PRE
/sbin/iptables curl -u test:test-t nat --delete POSTROUTING --jump IPT_WR_POST
/sbin/iptables curl -u test:test-t nat --flush IPT_WR_PRE
/sbin/iptables curl -u test:test-t nat --flush IPT_WR_POST
/sbin/iptables curl -u test:test-t nat --delete-chain IPT_WR_PRE
/sbin/iptables curl -u test:test-t nat --delete-chain IPT_WR_POST

exit 0
#!/bin/bash

export __dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -x

rm -f ${__dir}/src/log/*.log
rm -f ${__dir}/src/config.yml
rm -f ${__dir}/src/ipt.db

exit 0
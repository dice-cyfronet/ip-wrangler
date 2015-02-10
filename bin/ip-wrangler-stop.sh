#!/bin/bash

export __dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export __dir=$( dirname ${__dir} )

pushd ${__dir}/lib/ 2>&1 >> /dev/null
    thin stop
popd 2>&1 >> /dev/null

exit 0

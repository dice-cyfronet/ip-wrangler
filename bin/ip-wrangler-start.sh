#!/bin/bash

export __dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export __dir=$( dirname ${__dir} )

export __port=8400
export __ip=0.0.0.0
export __tag=IptWr
export __daemon=-d

function usage() {
    echo "Usage: $0 -i <ip> -p <port> -t <tag> -F (foreground mode) -h (help and exit)"
}

while getopts 'i:p:t:Fh' __flag; do
  case "${__flag}" in
    i)
        export __ip=${OPTARG}
        ;;
    p)
        export __port=${OPTARG}
        ;;
    t)
        export __tag=${OPTARG}
        ;;
    F)
        export __daemon=
        export __no_log=1
        ;;
    h)
        usage
        exit 0
        ;;
    *)
        error "Unexpected option: ${__flag}"
        usage
        exit 1
        ;;
  esac
done

pushd ${__dir}/lib/ 2>&1 >> /dev/null
    thin ${__daemon} -a ${__ip} -p ${__port} -R ./config.ru --tag ${__tag} start
popd 2>&1 >> /dev/null

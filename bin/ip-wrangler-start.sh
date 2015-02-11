#!/bin/bash

export __dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export __dir=$( dirname ${__dir} )

export __port=8400
export __ip=0.0.0.0
export __tag=IptWr
export __daemon=-d

function usage() {
    echo "Usage: $(basename $0) -c <config_file> -P <pid_file> -i <ip> -p <port> -t <tag> -F (foreground mode) -h (help and exit)"
}

while getopts 'c:P:i:p:t:Fh' __flag; do
  case "${__flag}" in
    c)
        export __config_file="$(realpath ${OPTARG})"
        ;;
    P)
        touch ${OPTARG}
        export __pid_file="$(realpath ${OPTARG})"
        ;;
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

if [ ! -z "${__daemon}" ] && [ -z "${__pid_file}" ]
then
    echo "No PID file defined in daemon mode."
    usage
    exit 1
fi

if [ ! -z "${__pid_file}" ]
then
    __pid_option="-P ${__pid_file}"
fi

if [ -z "${__config_file}" ]
then
    echo "No config file defined."
    usage
    exit 1
fi

pushd ${__dir}/lib/ 2>&1 >> /dev/null
    thin ${__daemon} ${__pid_option} -a ${__ip} -p ${__port} -R ./config.ru --tag ${__tag} start
popd 2>&1 >> /dev/null

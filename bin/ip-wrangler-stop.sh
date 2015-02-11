#!/bin/bash

export __dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export __dir=$( dirname ${__dir} )

function usage() {
    echo "Usage: $(basename $0) -P <pid_file> -h (help and exit)"
}

while getopts 'P:h' __flag; do
  case "${__flag}" in
    P)
        export __pid_file="$(realpath ${OPTARG})"
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

if [ -z "${__pid_file}" ]
then
    echo "No PID file defined."
    usage
    exit 1
fi

pushd ${__dir}/lib/ 2>&1 >> /dev/null
    thin -P ${__pid_file} stop
popd 2>&1 >> /dev/null

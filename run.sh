#!/bin/bash

export __DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export __PORT=8400
export __IP=0.0.0.0
export __TAG=IptWr

while getopts 'i:p:t:' __FLAG; do
  case "${__FLAG}" in
    i)
        export __IP=${OPTARG}
        ;;
    p)
        export __PORT=${OPTARG}
        ;;
    t)
        export __TAG=${OPTARG}
        ;;
    *)
        error "Unexpected option ${__FLAG}"
        ;;
  esac
done

thin -a ${__IP} -p ${__PORT} -R ${__DIR}/config.ru --tag ${__TAG} start
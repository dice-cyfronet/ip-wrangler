#!/bin/bash

export __DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export __PORT=8400
export __IP=0.0.0.0
export __TAG=IptWr
export __LOG_DIR=log/
export __CONSOLE_LOG=ipt_wr_console.log
export __CONSOLE_LOG_ERR=ipt_wr_console_err.log

while getopts 'i:p:t:' __FLAG; do
  case "${__FLAG}" in
    i)
        export __PORT=${OPTARG}
        ;;
    p)
        export __IP=${OPTARG}
        ;;
    t)
        export __TAG=${OPTARG}
        ;;
    *)
        error "Unexpected option ${__FLAG}"
        ;;
  esac
done

cd ${__DIR}
mkdir -p ${__LOG_DIR}
rm -f ${__LOG_DIR}/${__CONSOLE_LOG} ${__LOG_DIR}/${__CONSOLE_LOG_ERR}
touch ${__LOG_DIR}/${__CONSOLE_LOG} ${__LOG_DIR}/${__CONSOLE_LOG_ERR}
thin -a ${__IP} -p ${__PORT} -R config.ru --tag ${__TAG} start  > >(tee ${__LOG_DIR}/${__CONSOLE_LOG}) 2> >(tee ${__LOG_DIR}/${__CONSOLE_LOG_ERR} >&2)
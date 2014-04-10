#!/bin/bash

export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${DIR}
thin -a 192.168.122.94 -p 8400 -R config.ru --tag IptWr start
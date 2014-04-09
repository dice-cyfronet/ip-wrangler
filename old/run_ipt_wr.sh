#!/bin/bash

#cd iptwr_user_dir
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${DIR}
thin -a 127.0.0.1 -p 8400 -R config.ru --tag IptWr start

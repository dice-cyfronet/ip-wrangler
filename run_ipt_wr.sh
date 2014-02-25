#!/bin/bash

#cd iptwr_user_dir

thin -a 127.0.0.1 -p 8400 -R config.ru --tag IptWr start

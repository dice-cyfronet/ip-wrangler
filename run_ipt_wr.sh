#!/bin/bash

cd iptwr_user_dir

thin -a <IP> -p <PORT> -R config.ru -d --tag IptWr start

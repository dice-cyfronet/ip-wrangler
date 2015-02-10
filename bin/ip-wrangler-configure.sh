#!/bin/bash

export __dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export __dir="$(dirname ${__dir})"

if [ -z "$1" ]
then
    echo "Usage: $0 <path_to_config_file>"
    exit 1
fi

path_to_config_file=$1

echo "For more information, check: https://github.com/dice-cyfronet/ip-wrangler#configuration"

echo "====="

echo "Would like to override config with default settings?"
cp -i ${__dir}/config.yml.example ${path_to_config_file}

__log_dir="$(cat ${path_to_config_file} | grep log_dir: | awk '{print $2}')"
__db_path="$(cat ${path_to_config_file} | grep db_path: | awk '{print $2}')"
__username="$(cat ${path_to_config_file} | grep username: | awk '{print $2}')"
__password="$(cat ${path_to_config_file} | grep password: | awk '{print $2}')"
__iptables_chain_name="$(cat ${path_to_config_file} | grep iptables_chain_name: | awk '{print $2}')"
__ext_ip="$(cat ${path_to_config_file} | grep ext_ip: | awk '{print $2}')"
__port_ip="$(cat ${path_to_config_file} | grep port_ip: | awk '{print $2}')"
__port_start="$(cat ${path_to_config_file} | grep port_start: | awk '{print $2}')"
__port_stop="$(cat ${path_to_config_file} | grep port_stop: | awk '{print $2}')"

echo "====="

echo "Log directory (current value: \"${__log_dir}\", leave empty to use the same)"
read __new_log_dir
echo "Path to database file (current value: \"${__db_path}\", leave empty to use the same)"
read __new_db_path

echo "HTTP Username (current value: \"${__username}\", leave empty to use the same)"
read __new_username
echo "HTTP Password (current value: \"${__password}\", leave empty to use the same)"
read __new_password

echo "Iptables chains prefix (current value: \"${__iptables_chain_name}\", leave empty to use the same)"
read __new_iptables_chain_name

echo "External IP address user for NAT port. If your server is indicated by a different address than that assigned to the interface, enter it here. (current value: \"${__ext_ip}\", leave empty to use the same)"
read __new_ext_ip
echo "Public IP address used for NAT port. Enter address which is assigned to the interface. (current value: \"${__port_ip}\", leave empty to use the same)"
read __new_port_ip
echo "Begin of available port for NAT (current value: \"${__port_start}\")"
read __new_port_start
echo "End of available port for NAT (current value: \"${__port_stop}\")"
read __new_port_stop

echo "To update list of public IP used for NAT IP, use your favorite text editor, to edit \`${path_to_config_file}\`"

function check_and_replace() {
    __new_value="__new_${1}"
    __value="__${1}"
    if [ ! -z "${!__new_value}" ] && [ "${!__value}" != "${!__new_value}" ]; then
        sed -i "s/${1}:.*/${1}: ${!__new_value}/g" ${path_to_config_file}
    fi
}

check_and_replace log_dir
check_and_replace db_path
check_and_replace username
check_and_replace password
check_and_replace iptables_chain_name
check_and_replace ext_ip
check_and_replace port_ip
check_and_replace port_start
check_and_replace port_stop

echo "====="
echo "Show ${path_to_config_file}. You may edit this file to add IP which will use to IP mapping."
echo "-----"
cat ${path_to_config_file}

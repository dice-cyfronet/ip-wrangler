#!/bin/bash

export __dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export __dir="$(dirname ${__dir})"

pushd ${__dir}/lib 2>&1 >> /dev/null
    echo "For more information, check: https://github.com/dice-cyfronet/ip-wrangler#configuration"

    echo "====="

    cp -i config.yml.example config.yml

    __username="$(cat config.yml | grep username: | awk '{print $2}')"
    __password="$(cat config.yml | grep password: | awk '{print $2}')"
    __ext_ip="$(cat config.yml | grep ext_ip: | awk '{print $2}')"
    __port_ip="$(cat config.yml | grep port_ip: | awk '{print $2}')"
    __port_start="$(cat config.yml | grep port_start: | awk '{print $2}')"
    __port_stop="$(cat config.yml | grep port_stop: | awk '{print $2}')"

    echo "====="

    echo "HTTP Username (current value: \"${__username}\", leave empty to use the same)"
    read __new_username
    echo "HTTP Password (current value: \"${__password}\", leave empty to use the same)"
    read __new_password
    echo "External IP address user for NAT port. If your server is indicated by a different address than that assigned to the interface, enter it here. (current value: \"${__ext_ip}\", leave empty to use the same)"
    read __new_ext_ip
    echo "Public IP address used for NAT port. Enter address which is assigned to the interface. (current value: \"${__port_ip}\", leave empty to use the same)"
    read __new_port_ip
    echo "Begin of available port for NAT (current value: \"${__port_start}\")"
    read __new_port_start
    echo "End of available port for NAT (current value: \"${__port_stop}\")"
    read __new_port_stop
    echo "To update list of public IP used for NAT IP, use your favorite text editor, to edit \`config.yml\`"

    function check_and_replace() {
        __new_value="__new_${1}"
        __value="__${1}"
        if [ ! -z "${!__new_value}" ] && [ "${!__value}" != "${!__new_value}" ]; then
            sed -i "s/${1}:.*/${1}: ${!__new_value}/g" config.yml
        fi
    }

    check_and_replace username
    check_and_replace password
    check_and_replace ext_ip
    check_and_replace port_ip
    check_and_replace port_start
    check_and_replace port_stop

    echo "====="
    echo "Show config.yml"
    echo "-----"
    cat config.yml

popd 2>&1 >> /dev/null

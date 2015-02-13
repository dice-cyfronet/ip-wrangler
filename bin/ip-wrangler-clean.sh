#!/bin/bash

# It removes iptables rules, created by Ip-Wrangler, which are NAT to nowhere.

usage() { echo "Usage: $(basename $0) -n(ova_list) <path/to/file/with/nova_list.dump> -U(ser IpWrangler) <user> -P(assword IpWrangler) <password> -u(rl IpWrangler) <URL|maybe:http://127.0.0.1:8400> -p(refix) <IpPrefix|maybe:192.168.0>" 1>&2; exit 0; }

while getopts ":n:U:P:u:p:" __opts; do
    case "${__opts}" in
        n)
            export nova_list_path=${OPTARG}
            ;;
        U)
            export user=${OPTARG}
            ;;
        P)
            export password=${OPTARG}
            ;;
        u)
            export url=${OPTARG}
            ;;
        p)
            export prefix=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "${nova_list_path}" ] || [ -z "${user}" ] || [ -z "${password}" ] || [ -z "${url}" ] || [ -z "${prefix}" ]
then
    usage
fi

nova_list=$(cat ${nova_list_path})
for ppp in $(for pp in $(curl -u ${user}:${password} ${url}/dnat | sed 's/\",\"/ /g' | sed 's/\[\"//g' | sed 's/\"\]//g')
do
    echo ${pp}
done | sort | uniq | grep ${prefix})
do
    echo "${ppp} --->"
    echo "${nova_list}" | grep "${ppp} "

    is_vm=$(echo "${nova_list}" | grep "${ppp} " | wc -l)
    if [ ${is_vm} == 0 ]
    then
        echo "VM not exists!"
        __output=$(nmap ${ppp} | grep down)
        echo ${__output}
        is_vm_down=$(echo "${__output}" | wc -l)
        if [ ${is_vm_down} == 1 ]
        then
            echo "Do you want to delete this IP: ${ppp}? Answer \"yes\": "
            read answer
            if [ "${answer}" == "yes" ]
            then
                curl -u ${user}:${password} -X DELETE --data "" ${url}/dnat/${ppp}
            fi
        fi
    fi
done

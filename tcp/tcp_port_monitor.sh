#!/bin/bash
#Check system Whether or not  other port or services. (except 25|22|111|631|10050)

function lsof_key {
    netstat -tnlp | sed -e '1,2d' -e '/-/d' | awk '{print $4}' | awk -F':' '{if($NF~/^[0-9]*$/) print $NF}' | sort -n | uniq | grep -Ev "25|22|111|631|10050" &>/dev/null
    if [ $? -eq 0 ];then
        printf '1\n'
    else
        printf '0\n'
    fi
}
lsof_key

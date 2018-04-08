#!/bin/bash
#zabbix discovery oracle tablespace
table_spaces=(`cat /tmp/ora_tablespace.txt | sed -e "1,3d" -e "/^$/d" -e "/selected/d" | awk '{print $1}'`)
length=${#table_spaces[@]}

printf "{\n"
printf '\t'"\"data\":["
for ((i=0;i<$length;i++))
do
    printf "\n\t\t{"
    printf "\"{#TABLESPACE_NAME}\":\"${table_spaces[$i]}\"}"
    if [ $i -lt $[$length-1] ];then
        printf ","
    fi
done
    printf "\n\t]\n"
printf "}\n"


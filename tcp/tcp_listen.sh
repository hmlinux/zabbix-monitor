#!/bin/bash
#port_array=`netstat -tnlp | sed -e '1,2d' -e '/-/d' | awk '{print $4}' | awk -F':' '{if($NF~/^[0-9]*$/) print $NF}' | sort -n | uniq`
port_array=`netstat -ntlp | sed -e '1,2d' -e '/-/d' | awk '{print $4" "$NF}' | awk -F'[:/ ]+' '($NF !~ /^[0-9]*$/) && ($2>18) {print $2" "$NF}' |sort -g|uniq`
tcp_ports=(`echo "$port_array"|cut -d" " -f1`)
proc_name=(`echo "$port_array"|cut -d" " -f2`)
length=${#tcp_ports[@]}

printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
do
        printf '\n\t\t{'
        printf '\n\t\t\t'
        printf "\"{#TCP_PORT}\":\"${tcp_ports[$i]}\","
        printf '\n\t\t\t'
        printf "\"{#TCP_NAME}\":\"${proc_name[$i]}\"}"
        if [ $i -lt $[$length-1] ];then
                printf ','
        fi
done
printf  "\n\t]\n"
printf "}\n"

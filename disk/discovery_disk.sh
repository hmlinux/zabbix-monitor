#!/bin/bash
#disk discovery script
#mail: mail@huangming.org
disk_array=(`cat /proc/diskstats | grep -E "\b(sd[abcdefg])\b|\b(vd[abcdefge])\b|\b(xvd[abcdefg])\b|\b(hd[abcdef])\b" | grep -i "\b$1\b" | awk '{print $3}'|sort|uniq 2>/dev/null`)

length=${#disk_array[@]}
printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
do
    printf "\n\t\t{"
    printf "\"{#DISK_NAME}\":\"${disk_array[$i]}\"}"
    if [ $i -lt $[$length-1] ];then
        printf ","
    fi
done
    printf "\n\t]\n"
printf "}\n"

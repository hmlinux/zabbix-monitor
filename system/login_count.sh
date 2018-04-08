#!/bin/bash
# system login count
option=$1
count1=0
count3=0
count6=0
total0=$(last | grep -Ev "reboot|^$|wtmp" | wc -l)
login_file=/tmp/.login
who /var/log/wtmp > ${login_file} && chown zabbix. ${login_file}
d1=`date -d"1 month ago" +"%s"`
d3=`date -d"3 month ago" +"%s"`
d6=`date -d"6 month ago" +"%s"`

IFS=$'\n'
for i in `cat $login_file`
do
    riqi=`echo $i | awk '{ print $3" "$4" "$5 }' | xargs -i  date -d "{}" "+%s"`
    if [ "$riqi" -gt "$d1" ];then
        count1=$[ $count1 + 1 ]
        sed -i '/${i}/d' $login_file
    fi
    if [ "$riqi" -gt "$d3" ];then
        count3=$[ $count3 + 1 ]
    fi
    if [ "$riqi" -gt "$d6" ];then
        count6=$[ $count6 + 1 ]
    fi
done

case $option in
    d1)
        echo ${count1} ;;
    d3)
        echo ${count3} ;;
    d6)
        echo ${count6} ;;
    d0)
        echo ${total0} ;;
    *)
        echo -e "Usage: sh $0 [d1|d3|d6|d0]"
esac

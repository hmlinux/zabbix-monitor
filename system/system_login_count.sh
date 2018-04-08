#!/bin/bash
# system login count
option=$1
count1=0
count3=0
count6=0
total0=$(last | grep -Ev "\b((reboot)|(wtmp)|(10.17.82.20)|(10.17.87.20)|(10.0.6.20)|(192.168.6.20))\b" | grep -v "^$" | wc -l)
ttyconsole=$(last | grep tty | wc -l)
ansible_ssh=$(who /var/log/wtmp | grep -E "\b((10.17.82.20)|(10.17.87.20)|(10.0.6.20)|(192.168.6.20))\b" | wc -l)
login_file=/tmp/.login
who /var/log/wtmp | grep -Ev "\b((10.17.82.20)|(10.17.87.20)|(10.0.6.20)|(192.168.6.20))\b" | grep "pts/" > ${login_file}
d1=$(date -d"1 month ago" +"%s")
d3=$(date -d"3 month ago" +"%s")
d6=$(date -d"6 month ago" +"%s")

function foo {
IFS=$'\n'
for i in `cat $login_file`
do
    riqi=`echo $i | awk '{ print $3" "$4" "$5 }' | xargs -i date -d "{}" "+%s"`
    if [ "$riqi" -gt "$d1" ];then
        count1=$[ $count1 + 1 ]
    fi
    if [ "$riqi" -gt "$d3" ];then
        count3=$[ $count3 + 1 ]
    fi
    if [ "$riqi" -gt "$d6" ];then
        count6=$[ $count6 + 1 ]
    fi
done
}

case $option in
    avg1)
        foo
        echo ${count1} ;;
    avg3)
        foo
        echo ${count3} ;;
    avg6)
        foo
        echo ${count6} ;;
    avg0)
        echo ${total0} ;;
    ansible)
        echo ${ansible_ssh} ;;
    ttyconsole)
        echo ${ttyconsole} ;;
    *)
        echo -e "Usage: sh $0 [avg1|avg3|avg6|avg0|ttyconsole]"
esac

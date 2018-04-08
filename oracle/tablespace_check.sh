#!/bin/bash
# oracle tablespace check
CEHCK_TYPE=$1
TABLESPACE_NAME=$2

function usagepre {
    grep "\b$TABLESPACE_NAME\b" /tmp/ora_tablespace.txt | awk '{printf "%.f\n",($2-$3)/$2*100}'
}

function available {
    grep "\b$TABLESPACE_NAME\b" /tmp/ora_tablespace.txt | awk '{printf $3*1024*1024}'
}

function check {
    if grep "\b$TABLESPACE_NAME\b" /tmp/ora_autex.txt | awk '{print $2}' | uniq | grep "YES" &>/dev/null;then
        echo 1
    else
        echo 0
    fi
}

case $CEHCK_TYPE in
    pre)
        usagepre ;;
    fre)
        available ;;
    check)
        check ;;
    *)
        echo -e "Usage: $0 [pre|fre|check] [TABLESPACE_NAME]"
esac

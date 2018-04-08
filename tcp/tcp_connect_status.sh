#!/bin/bash
#Author: HMLinux  Email: mail@huangming.org
parameter_l=$1
parameter_u=$(echo $parameter_l | tr '[:lower:]' '[:upper:]')
ptcp_status=$(/bin/netstat -an|awk '/^tcp/{++S[$NF]}END{for(a in S) print a,S[a]}' | awk '/'''$parameter_u'''/{print $2}')
case $parameter_l in 
    listen)
        if [ "$ptcp_status" == "" ];then
            echo 0
        else
            echo $ptcp_status
        fi
     ;;
    established)
        if [ "$ptcp_status" == "" ];then
            echo 0
        else
            echo $ptcp_status
        fi
     ;; 
    time_wait)
        if [ "$ptcp_status" == "" ];then
            echo 0
        else
            echo $ptcp_status
        fi
     ;;
    syn_sent)
        if [ "$ptcp_status" == "" ];then
            echo 0
        else
            echo $ptcp_status
        fi
     ;;
    syn_recv)
        if [ "$ptcp_status" == "" ];then
            echo 0
        else
            echo $ptcp_status
        fi
     ;;
    closing)
        if [ "$ptcp_status" == "" ];then
            echo 0
        else
            echo $ptcp_status
        fi
     ;;
    close_wait)
        if [ "$ptcp_status" == "" ];then
            echo 0
        else
            echo $ptcp_status
        fi
     ;;
    fin_wait1)
        if [ "$ptcp_status" == "" ];then
            echo 0
        else
            echo $ptcp_status
        fi
     ;;
    fin_wait2)
        if [ "$ptcp_status" == "" ];then
            echo 0
        else
            echo $ptcp_status
        fi
     ;;
    lastack)
        if [ "$ptcp_status" == "" ];then
            echo 0
        else
            echo $ptcp_status
        fi
     ;;

     *)
        echo -e "\E[33mUsage: sh $0 [closed|closing|close_wait|syn_recv|syn_sent|fin_wait1|fin_wait2|listen|established|lastack|time_wait]\E[0m"
esac


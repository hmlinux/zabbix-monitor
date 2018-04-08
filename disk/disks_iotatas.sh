#!/bin/bash
#disk iostat
case $2 in
    read.count)
        cat /proc/diskstats | grep $1 | head -1 | awk '{print $4}' ;;
    write.count)
        cat /proc/diskstats | grep $1 | head -1 | awk '{print $8}' ;;
    read.merge)
        cat /proc/diskstats | grep $1 | head -1 | awk '{print $5}' ;;
    write.merge)
        cat /proc/diskstats | grep $1 | head -1 | awk '{print $9}' ;;
    read.sectors)
        cat /proc/diskstats | grep $1 | head -1 | awk '{print $6}' ;;
    write.sectors)
        cat /proc/diskstats | grep $1 | head -1 | awk '{print $10}' ;;
    io.count)
        cat /proc/diskstats | grep $1 | head -1 | awk '{print $12}' ;;
    read.sec)
        cat /proc/diskstats | grep $1 | head -1 | awk '{print $7}' ;;
    write.sec)
        cat /proc/diskstats | grep $1 | head -1 | awk '{print $11}' ;;
    io.sec)
        cat /proc/diskstats | grep $1 | head -1 | awk '{print $13}' ;;
    io.sec.weight)
        cat /proc/diskstats | grep $1 | head -1 | awk '{print $14}' ;;
    *)
        echo -e "Usage: $0 [disk name] [read.count|write.count|read.merge|write.merge|read.sectors|write.sectors|io.count|read.sec|write.sec|io.sec|io.sec.weight]"
esac

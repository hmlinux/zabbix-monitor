#!/bin/bash
zabbix_base=/usr/local/zabbix
zabbix_agentd_conf=$zabbix_base/etc/zabbix_agentd.conf

start() {
    /usr/local/sbin/zabbix_agentd -c $zabbix_base/etc/zabbix_agentd.conf
    [ $? -eq 0 ] && touch /var/lock/subsys/zabbix_agentd
    echo -e "Starting Zabbix Agent:\t\t[  OK  ]"
}

stop() {
    pkill zabbix_agentd
    rm -f /var/lock/subsys/zabbix_agentd
    echo -e "Stopping Zabbix Agent:\t\t[  OK  ]"
}

case $1 in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        sleep 3
        start
        ;;
    *)
        echo -e "Usage: $0 [start|stop|restart|]"
esac

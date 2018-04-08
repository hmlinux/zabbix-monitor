#!/bin/bash
zabbix_base1=/opt/zabbix
zabbix_base2=/usr/local/zabbix

if [ -d $zabbix_base1 ];then
    zabbix_base=$zabbix_base1
    mkdir $zabbix_base/scripts &>/dev/null
elif [ -d $zabbix_base2 ];then
    zabbix_base=$zabbix_base2
    mkdir $zabbix_base/scripts &>/dev/null
else
    echo "Not found zabbix_agentd!"
    exit 1
fi

# check os
if [ -f /etc/redhat-release ];then
    os=rh
elif [ -f /etc/SuSE-release ];then
    os=se
fi

function sync_date {
    if [ "$os" = "se" ];then
	sntp -P no -r 10.17.87.8 || sntp -P no -r 10.17.82.8 && hwclock -w
    else
	ntpdate 10.17.87.8 || ntpdate 10.17.82.8 && hwclock -w
    fi
};sync_date


# system monitor scripts ---------------------------------
function add_tcp_script {
cat > $zabbix_base/scripts/discovery_tcp_port.sh << EOF
#!/bin/bash
port_array=\`netstat -ntlp | sed -e '1,2d' -e '/-/d' | awk '{print \$4" "\$NF}' | awk -F'[:/ ]+' '(\$NF !~ /^[0-9]*$/) && (\$2>18) {print \$2" "\$NF}' |sort -g|uniq\`
tcp_ports=(\`echo "\$port_array"|cut -d" " -f1\`)
proc_name=(\`echo "\$port_array"|cut -d" " -f2\`)
length=\${#tcp_ports[@]}

printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<\$length;i++))
do
        printf '\n\t\t{'
        printf '\n\t\t\t'
        printf "\"{#TCP_PORT}\":\"\${tcp_ports[\$i]}\","
        printf '\n\t\t\t'
        printf "\"{#TCP_NAME}\":\"\${proc_name[\$i]}\"}"
        if [ \$i -lt \$[\$length-1] ];then
                printf ','
        fi
done
printf  "\n\t]\n"
printf "}\n"
EOF
}

# crontab ------------------------------------------------
function add_cron_root_suse {
sed -i "/\/usr\/sbin\/sntp -P no -r/d"  /var/spool/cron/tabs/root &>/dev/null
sed -i "/discovery_tcp_port.sh/d"  /var/spool/cron/tabs/root &>/dev/null

cat >>  /var/spool/cron/tabs/root << EOF
30 10 * * * /usr/sbin/sntp -P no -r 10.17.87.8 &>/dev/null
EOF
/etc/init.d/cron restart || systemctl restart crond
}

function add_cron_root_rhel {
sed -i "/\/usr\/sbin\/ntpdate/d" /var/spool/cron/root &>/dev/null
sed -i "/discovery_tcp_port.sh/d" /var/spool/cron/root &>/dev/null

cat >> /var/spool/cron/root << EOF
30 10 * * * /usr/sbin/ntpdate 10.17.87.8 &>/dev/null
EOF
/etc/init.d/crond restart || systemctl restart crond
}

system_crontab() {
    if [ "$os" = "se" ];then
	add_cron_root_suse
    elif [ "$os" = "rh" ];then
	add_cron_root_rhel
    else
	add_cron_root_rhel
    fi
}

# zabbix agentd configure ---------------------------------
function config_zabbix {
# configure zabbix_agentd_conf
sed -i "/# Include=\/usr\/local\/etc\/zabbix_agentd.conf.d\/\*.conf/cInclude=${zabbix_base}/etc/zabbix_agentd.conf.d" ${zabbix_base}/etc/zabbix_agentd.conf &>/dev/null
sed -i "/# UnsafeUserParameters=0/cUnsafeUserParameters=1" ${zabbix_base}/etc/zabbix_agentd.conf &>/dev/null
sed -i "/^# Timeout=/cTimeout=8" ${zabbix_base}/etc/zabbix_agentd.conf &>/dev/null

# configure sudoers
sed -i "/Defaults:zabbix    \!requiretty/d" /etc/sudoers &>/dev/null
sed -i "/zabbix  ALL=(ALL)/d" /etc/sudoers &>/dev/null
sed -i "\$aDefaults:zabbix    \!requiretty" /etc/sudoers
sed -i "\$azabbix  ALL=(ALL)       NOPASSWD: $zabbix_base/scripts/discovery_tcp_port.sh" /etc/sudoers

}

function add_parameters_file {
cat > $zabbix_base/etc/zabbix_agentd.conf.d/userparameter_script.conf << EOF
UserParameter=tcp_listen_port,sudo $zabbix_base/scripts/discovery_tcp_port.sh
EOF
}

main() {
    add_tcp_script && chmod 755 $zabbix_base/scripts/discovery_tcp_port.sh
    system_crontab
    config_zabbix
    add_parameters_file
    /etc/init.d/zabbix_agentd restart
};main

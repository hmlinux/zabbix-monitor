#!/bin/bash
# Author: hm  Email: mail@huangming.org
# Zabbix3.0.7-agent compiled automatically install script.
# System: Centos5-7 RHEL5-7 Suse11-12 opensuse

# Zabbix Server the first IP address.
Server=10.17.87.120
ServerActive=10.17.87.120:10050
DefaultServer=$Server
DefaultServerActive=$ServerActive

# Zabbix Server the second IP address.(Default no)
Server2=10.17.81.120
ServerActive2=10.17.81.120:10050

# Get the system ip address.
IPADDR1=`ip addr|awk -F"[/ ]+" '(/inet /) && ($0 !~ /lo$/) && ($0 !~ /virbr0$/){print $3}'|awk 'NR==1{print $0}'`
IPADDR2=`ip addr|awk -F"[/ ]+" '(/inet /) && ($0 !~ /lo$/) && ($0 !~ /virbr0$/){print $3}'|awk 'NR==2{print $0}'`

# Zabbix agentd hostname.
Hostname=$IPADDR1

# ntpserver: ntp1.aliyun.com
ntpserver=10.17.87.8

# zabbix-3.0.7.tar.gz download url: http://www.zabbix.com/download
zabbix_s=zabbix-3.0.7.tar.gz
zabbix_d=zabbix-3.0.7
zabbix_url=http://10.17.87.6/source/zabbix-3.0.7.tar.gz
Basedir=/usr/local/zabbix

Network=10.17.87
Filter_IP1=`echo $IPADDR1 | awk -F. '{print $1"."$2"."$3}'`
Filter_IP2=`echo $IPADDR2 | awk -F. '{print $1"."$2"."$3}'`
if [ "$Filter_IP1" != $Network -a "$Filter_IP2" != $Network ];then
    Server=$Server2
    ServerActive=$ServerActive2
    DefaultServer=$Server2
    DefaultServerActive=$ServerActive2
fi

Selinux() {
    sed -i "/^SELINUX=/cSELINUX=disabled" /etc/selinux/config
    setenforce 0
};Selinux &>/dev/null

CHK_OS() {
    RH_V=`uname -r | awk -F"." '{print $4}'`
    if [ -f /etc/redhat-release ];then
        if [ "$RH_V" = "el6" ];then
            OS=rhel6
        elif [ "$RH_V" = "el7" ];then
            OS=rhel7
        else
            OS=rhel5
        fi
	PI=yum
    elif [ -f /etc/SuSE-release ];then
        SE_V=`cat /etc/SuSE-release | awk 'NR==1 {print $1$5}'`
        if [ "$SE_V" = "SUSE11" ];then
            SE_VV=`cat /etc/issue | awk '/SUSE/{print $3$7$8}'`
            if [ "$SE_VV" = "SUSE11SP3" ];then
                OS=suse11sp3
	    elif [ "$SE_VV" = "SUSE11SP4" ];then
                OS=suse11sp4
	    fi
	elif [ "$SE_V" = "SUSE12" ];then
	    OS=suse12
        elif [ "$SE_V" = "openSUSE" ];then
            OS=opensuse
        else
            OS=suse10
        fi
	PI=zypper
    elif [ "$RH_V" = "el6" ];then
	OS=rhel6
	PI=yum
    else
        echo "Operating system does not support."
        exit 1
    fi
};CHK_OS

Install_dep() {
    for p in gcc gcc-c++ wget ntpdate
    do
        if ! rpm -qa | grep -q ^$p;then
            $PI install -y $p >/dev/null 2>&1
        fi
    done
    ntpdate $ntpserver &>/dev/null && hwclock -w
    sntp -P no -r $ntpserver &>/dev/null && hwclock -w
}

# Add the package mirrors source, and you can manual download the repos. go to http://mirrors.aliyun.com/epel/ 
# CentOS6 Configuration method:
# 1. shell# mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
# 2. shell# wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
#
Check_and_add_repos() {
    if [ "$OS" == "suse11sp3" ];then
	zypper ar http://10.17.87.6/iso/SLES-11-SP3-x86_64/ SLES-11-SP3-x86_64
	Install_dep
    elif [ "$OS" == "suse11sp4" ];then
	zypper ar http://10.17.82.25/iso/SLES-11-SP4-x86_64/ SLES-11-SP4-x86_64
	Install_dep
    elif [ "$OS" == "suse12" ];then
	zypper ar http://10.17.82.25/iso/SLES-12-x86_64/ SLES-12-x86_64
	Install_dep
    elif [ "$OS" == "rhel6" -o "$OS" == "rhel7" -o "$OS" == "rhel5" ];then
	Release=`cat /etc/redhat-release | awk '{print $1$2$(NF-1)}' | awk -F. '{print $1}' | sed -e 's/release//g' -e 's/Linux//g'`
        Install_dep
    else
	Install_dep
    fi
}

Download_zabbix() {
    if [ ! -e /usr/local/src/$zabbix_s ];then
        wget $zabbix_url -P /usr/local/src
	if [ $? -ne 0 ];then
	    echo -e "\E[31mCan't download, Please upload the $zabbix_s to [/usr/local/src/].\E[0m"
	    exit 1
	fi
    fi
}

Create_zabbix_user() {
    if ! /usr/bin/id zabbix &>/dev/null;then
	groupadd zabbix && useradd -g zabbix zabbix -M
    fi
}

Compile_zabbix_agentd() {
    [ -d $Basedir ] || mkdir $Basedir
    cd /usr/local/src && tar -zxf $zabbix_s && cd $zabbix_d
    ./configure --prefix=$Basedir --enable-agent
    make && make install
}

Copy_agentd_init() {
    rm -rf /usr/local/sbin/zabbix_agentd && ln -s $Basedir/sbin/zabbix_agentd /usr/local/sbin/
    rm -rf /etc/init.d/zabbix_agentd
    cd /usr/local/src/$zabbix_d
    if [ "$OS" == "rhel6" -o "$OS" == "rhel7" -o "$OS" == "rhel5" ];then
        cp misc/init.d/fedora/core5/zabbix_agentd /etc/init.d/ && chmod 755 /etc/init.d/zabbix_agentd
        chkconfig --add zabbix_agentd
        chkconfig --level 1235 zabbix_agentd on
    elif [ "$OS" == "suse11sp3" -o "$OS" == "suse11sp4" -o "$OS" == "suse12" -o "$OS" == "suse10" -o "$OS" == "opensuse" ];then
        cp misc/init.d/suse/9.3/zabbix_agentd /etc/init.d/ && chmod 755 /etc/init.d/zabbix_agentd
        chkconfig --add zabbix_agentd
	chkconfig --level 1235 zabbix_agentd on
    fi
}

Zabbix_agentd_conf() {
    sed -i "/^Server=/cServer=$Server" $Basedir/etc/zabbix_agentd.conf
    sed -i "/^ServerActive=/cServerActive=$ServerActive" $Basedir/etc/zabbix_agentd.conf
    sed -i "/^Hostname=/cHostname=$Hostname" $Basedir/etc/zabbix_agentd.conf
}

Setup_agentd() {
echo -en "\
-------------------
Setup zabbix agentd.
Zabbix agentd configure file is $Basedir/etc/zabbix_agentd.conf.
Default:
  \E[34mServer=$Server\E[0m
  \E[34mServerActive=$ServerActive\E[0m
  \E[34mHostname=$Hostname\E[0m (You can change it.)
The localhost ip address is: $IPADDR1  $IPADDR2
Do you want change the Server and ServerActive configuration?(yes|no)"
read option
if [ "U$option" = "Uyes" -o "U$option" = "Uy" -o "U$option" = "UY" ];then
    echo -en "Enter the zabbix Server="; read Server_
    echo -en "Enter the zabbix ServerActive="; read ServerActive_
    echo -en "Enter the zabbix agentd Hostname="; read Hostname_
    read1=`echo $Server_ | grep -E "\b((([0-9]{1,2})|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5]))\.){3}(([0-9]{1,2})|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5]))\b"`
    read2=`echo $ServerActive_ |grep -E "\b((([0-9]{1,2})|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5]))\.){3}(([0-9]{1,2})|(1[0-9]{2})|(2[0-4][0-9])|(25[0-5]))\b"`
    if [ "U$read1" != "U" -a "U$read2" != "U" -a "U$Hostname_" != "U" ];then
	Server=$Server_
	ServerActive=$ServerActive_
	Hostname=$Hostname_
	Zabbix_agentd_conf
	echo commit.
    else
	Server=$DefaultServer
	ServerActive=$DefaultServerActive
	Hostname=$IPADDR1
	Zabbix_agentd_conf
    fi

else
    Zabbix_agentd_conf
fi

if [ "$OS" == "rhel7" -o "$OS" == "suse12" ];then
    systemctl daemon-reload
    systemctl start zabbix_agentd
    firewall-cmd --permanent --add-port=10050/tcp
    firewall-cmd --reload
else
    /etc/init.d/zabbix_agentd start
fi
}

Setup_iptables() {
    iptables -I INPUT -p all -s $Server -j ACCEPT;
    iptables -I INPUT -p all -s $Server_ -j ACCEPT >/dev/null 2>&1;
    if [ $? -ne 0 ];then
	iptables -I INPUT -p all -s $Server2 -j ACCEPT
    fi
    service iptables save;
    echo "Zabbix agent install finished."
}

Install() {
    if [ -e /usr/local/sbin/zabbix_agentd -o -e /usr/local/zabbix/sbin/zabbix_agentd -o \
-e $Basedir/sbin/zabbix_agentd ];then
        echo "Zabbix server or agentd is already install. "; exit 0
    else
	echo "Installing ..."
	echo
        Check_and_add_repos;
        Download_zabbix;
        Create_zabbix_user;
        Compile_zabbix_agentd;
        Copy_agentd_init;
	Zabbix_agentd_conf;
        Setup_agentd;
	Setup_iptables;
    fi
};Install


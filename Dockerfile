FROM blalor/centos
MAINTAINER Bernardo Gomez Palacio <bernardo.gomezpalacio@gmail.com>

# EPEL should already be available.
# Install Zabbix Repo
RUN rpm -ivh http://repo.zabbix.com/zabbix/2.0/rhel/6/x86_64/zabbix-release-2.0-1.el6.noarch.rpm 
RUN yum makecache
# Installing SSHD packages
RUN yum -y -q install openssh-server openssh-client
# Installing SNMP Utils
#RUN yum -y install libsnmp-dev libsnmp-base libsnmp-dev libsnmp-perl libnet-snmp-perl librrds-perl
RUN yum -y -q install net-snmp-devel net-snmp-libs net-snmp net-snmp-perl net-snmp-python net-snmp-utils
# Install Lamp Stack, including PHP5 SNMP
RUN yum -y -q install mysql mysql-server 
# Install Apache and PHP5
RUN yum -y -q install httpd php php-mysql php-snmp
# Additional Tools
RUN yum -y -q install pwgen vim
# Install zabbix server and php frontend
RUN yum -y -q install zabbix-server-mysql zabbix-frontend-php zabbix-web-mysql
# Cleaining up.
RUN yum clean all
# MySQL
ADD ./mysql/my.cnf /etc/mysql/conf.d/my.cnf

# Zabbix Conf Files
RUN cp /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.bkp
ADD ./zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf
RUN chmod 644 /etc/zabbix/zabbix_server.conf

RUN cp /etc/httpd/conf.d/zabbix.conf /etc/httpd/conf.d/zabbix.conf.bkp
ADD ./zabbix/httpd_zabbix.conf  /etc/httpd/conf.d/zabbix.conf

ADD ./zabbix/zabbix.conf.php 	/usr/share/zabbix/conf/zabbix.conf.php
ADD ./zabbix/zabbix.conf.php    /etc/zabbix/web/zabbix.conf.php


# ADD ./supervisord/supervisord.conf /etc/supervisord.conf
# Add the script that will start the repo.
ADD ./scripts/start.sh /start.sh

# Post-Run commands
RUN chmod 755 /start.sh
# zabbix, apache with zabbix ui, collectd, mysql
EXPOSE 10051 80 25826/udp 3306

CMD ["/bin/bash", "/start.sh"]
FROM centos
MAINTAINER Bernardo Gomez Palacio <bernardo.gomezpalacio@gmail.com>

# Update base images.
RUN yum distribution-synchronization -y

# Install EPEL, MySQL, Zabbix release packages.
RUN yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
#RUN yum install -y http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
RUN yum install -y http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm
# RUN rpm -ivh http://repo.zabbix.com/zabbix/2.0/rhel/6/x86_64/zabbix-release-2.0-1.el6.noarch.rpm 

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
RUN yum -y -q install passwd  perl-JSON python-simplevisor pwgen vim
# Install packages.
RUN yum -y -q install java-1.7.0-openjdk
# Install zabbix server and php frontend
RUN yum -y -q install zabbix-agent zabbix-get zabbix-java-gateway zabbix-sender zabbix-server zabbix-server-mysql zabbix-web zabbix-web-mysql
# Cleaining up.
RUN yum clean all
# MySQL
ADD ./mysql/my.cnf /etc/mysql/conf.d/my.cnf
# SSHD configuration
ADD sshd/sshd_config /etc/ssh/sshd_config
RUN chmod 600 /etc/ssh/sshd_config
# Zabbix Conf Files
ADD ./zabbix/zabbix.ini 				/etc/php.d/zabbix.ini
ADD ./zabbix/httpd_zabbix.conf  		/etc/httpd/conf.d/zabbix.conf
ADD ./zabbix/zabbix.conf.php    		/etc/zabbix/web/zabbix.conf.php
ADD ./zabbix/zabbix_agentd.conf 		/etc/zabbix/zabbix_agentd.conf
ADD ./zabbix/zabbix_java_gateway.conf 	/etc/zabbix/zabbix_java_gateway.conf
ADD ./zabbix/zabbix_server.conf 		/etc/zabbix/zabbix_server.conf

RUN chmod 640 /etc/zabbix/zabbix_server.conf
RUN chown root:zabbix /etc/zabbix/zabbix_server.conf

# ADD ./supervisord/supervisord.conf /etc/supervisord.conf
# Simplevisor
ADD ./simplevisor.conf /etc/simplevisor.conf

# https://github.com/dotcloud/docker/issues/1240#issuecomment-21807183
RUN echo "NETWORKING=yes" > /etc/sysconfig/network
# http://gaijin-nippon.blogspot.com/2013/07/audit-on-lxc-host.html
RUN sed -i -e '/pam_loginuid\.so/ d' /etc/pam.d/sshd
# Generate a host key before packing.
RUN service sshd start; service sshd stop
# Add the script that will start the repo.
ADD ./scripts/start.sh /start.sh
RUN chmod 755 /start.sh
# zabbix server, apache with zabbix ui, sshd
EXPOSE 10051 10052 80 22 
VOLUME ["/var/lib/mysql", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/etc/zabbix/zabbix_agentd.d"]
CMD ["/bin/bash", "/start.sh"]

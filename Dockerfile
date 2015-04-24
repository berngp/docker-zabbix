# Version 2.3

FROM centos:centos6
MAINTAINER Bernardo Gomez Palacio <bernardo.gomezpalacio@gmail.com>
ENV REFRESHED_AT 2015-03-19

# Install EPEL to have MySQL packages.
RUN yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
# Install Zabbix release packages.
RUN yum install -y http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-release-2.4-1.el6.noarch.rpm
# Refresh
RUN yum makecache
# Installing Tools.
RUN yum -y -q install \
              monit \
              nmap  \
              traceroute \
              wget  \
              sudo

# Installing SNMP Utils
# RUN yum -y install libsnmp-dev libsnmp-base libsnmp-dev libsnmp-perl libnet-snmp-perl librrds-perl
RUN yum -y -q install \
              net-snmp-devel  \
              net-snmp-libs   \
              net-snmp        \
              net-snmp-perl   \
              net-snmp-python \
              net-snmp-utils

# Install Lamp Stack, including PHP5 SNMP
RUN yum -y -q install \
              mysql \
              mysql-server

# Install Apache and PHP5 with ldap support
RUN yum -y -q install \
              httpd \
              php \
              php-mysql \
              php-snmp  \
              php-ldap

# Install packages.
RUN yum -y -q install java-1.8.0-openjdk \
                      java-1.8.0-openjdk-devel

COPY ./profile.d/java.sh /etc/profile.d/java.sh
RUN chmod 755 /etc/profile.d/java.sh

#RUN /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.25-3.b17.el6_6.x86_64/jre/bin/java
# Install Zabbix Server and PHP UI.
# Be aware of the Zabbix version number in the  zabbix22-dbfiles-mysql package(!).
RUN yum -y -q install zabbix-agent  \
              zabbix-get            \
              zabbix-java-gateway   \
              zabbix-sender         \
              zabbix-server         \
              zabbix-server-mysql   \
              zabbix-web            \
              zabbix-web-mysql      \
              zabbix22-dbfiles-mysql

# YUM Cleanup
RUN yum clean all && rm -rf /tmp/*

# MySQL
COPY ./mysql/my.cnf /etc/mysql/conf.d/my.cnf
# Get the tuneup kit
# https://major.io/mysqltuner/
RUN wget http://mysqltuner.pl -O /usr/local/bin/mysqltuner.pl
RUN chmod 755 /usr/local/bin/mysqltuner.pl

COPY ./sudoers.d/    /etc/sudoers.d/
# Zabbix Conf Files
COPY ./zabbix/zabbix.ini 				        /etc/php.d/zabbix.ini
COPY ./zabbix/httpd_zabbix.conf  		    /etc/httpd/conf.d/zabbix.conf
COPY ./zabbix/zabbix.conf.php    		    /etc/zabbix/web/zabbix.conf.php
COPY ./zabbix/zabbix_agentd.conf 		    /etc/zabbix/zabbix_agentd.conf
COPY ./zabbix/zabbix_java_gateway.conf 	/etc/zabbix/zabbix_java_gateway.conf
COPY ./zabbix/zabbix_server.conf 		    /etc/zabbix/zabbix_server.conf

RUN chmod 640 /etc/zabbix/zabbix_server.conf
RUN chown root:zabbix /etc/zabbix/zabbix_server.conf

# Monit
ADD ./monitrc /etc/monitrc
RUN chmod 600 /etc/monitrc

# https://github.com/dotcloud/docker/issues/1240#issuecomment-21807183
RUN echo "NETWORKING=yes" > /etc/sysconfig/network

# Add the script that will start the repo.
ADD ./scripts/entrypoint.sh /bin/docker-zabbix
RUN chmod 755 /bin/docker-zabbix

# Expose the Ports used by
# * Zabbix services
# * Apache with Zabbix UI
# * Monit
EXPOSE 10051 10052 80 2812

VOLUME ["/var/lib/mysql", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/etc/zabbix/zabbix_agentd.d"]

ENTRYPOINT ["/bin/docker-zabbix"]
CMD ["run"]

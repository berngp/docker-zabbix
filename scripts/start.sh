#!/bin/bash

if [ ! -f /mysql-configured ]; then 
 	/sbin/service mysqld restart 

 	/usr/bin/mysql_upgrade

	 sleep 10s

	 MYSQL_PASSWORD="mypassword"

	 echo "mysql root and admin password: $MYSQL_PASSWORD"

	 echo "$MYSQL_PASSWORD" > /mysql-root-pw.txt

	 mysqladmin -uroot password $MYSQL_PASSWORD 

	 mysql -uroot -p"$MYSQL_PASSWORD" -e "INSERT INTO mysql.user (Host,User,Password) VALUES('%','admin',PASSWORD('${MYSQL_PASSWORD}'));"

	 mysql -uroot -p"$MYSQL_PASSWORD" -e "GRANT ALL ON *.* TO 'admin'@'%';"

	 mysqladmin -uroot -p"$MYSQL_PASSWORD" create zabbix

	 mysql -uroot -p"$MYSQL_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8;"

	 zabbix_mysql_v="$(ls -d /usr/share/doc/zabbix-server-mysql-*)"

	 mysql -uroot -D zabbix -p"$MYSQL_PASSWORD" < "${zabbix_mysql_v}/create/schema.sql"
	 mysql -uroot -D zabbix -p"$MYSQL_PASSWORD" < "${zabbix_mysql_v}/create/images.sql"
	 mysql -uroot -D zabbix -p"$MYSQL_PASSWORD" < "${zabbix_mysql_v}/create/data.sql"

	 mysql -uroot -p"$MYSQL_PASSWORD" -e "INSERT INTO mysql.user (Host,User,Password) VALUES('localhost','zabbix',PASSWORD('zabbix'));"

	 mysql -uroot -p"$MYSQL_PASSWORD" -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP ON zabbix.* TO 'zabbix'@'%';"

	 /sbin/service/mysql stop

	 touch /mysql-configured
fi

service sshd start
service mysqld restart
service httpd start
service zabbix-server start

# Jump into the BASH Shell
#/bin/bash 
# Jump to tail the Zabbix Server Log.
/usr/bin/tail -f /var/log/zabbix/zabbix_server.log
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

	 zabbix_mysql_v="/usr/share/zabbix-mysql"

	 mysql -uroot -D zabbix -p"$MYSQL_PASSWORD" < "${zabbix_mysql_v}/schema.sql"
	 mysql -uroot -D zabbix -p"$MYSQL_PASSWORD" < "${zabbix_mysql_v}/images.sql"
	 mysql -uroot -D zabbix -p"$MYSQL_PASSWORD" < "${zabbix_mysql_v}/data.sql"

	 mysql -uroot -p"$MYSQL_PASSWORD" -e "INSERT INTO mysql.user (Host,User,Password) VALUES('localhost','zabbix',PASSWORD('zabbix'));"

	 mysql -uroot -p"$MYSQL_PASSWORD" -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP ON zabbix.* TO 'zabbix'@'%';"

	 /sbin/service mysqld stop

	 touch /mysql-configured
fi

passwd -d root

/usr/bin/monit -d 10 -Ic /etc/monitrc

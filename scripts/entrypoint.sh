#!/bin/bash

source /etc/profile.d/java.sh

readonly _file_marker="/var/lib/mysql/.mysql-configured"

if [ ! -f "$_file_marker" ]; then
  /sbin/service mysqld restart

 	/usr/bin/mysql_upgrade

	sleep 10s

	export MYSQL_PASSWORD="mypassword"

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

	/sbin/service mysqld restart

  mysql -uroot -p"$MYSQL_PASSWORD" -e "GRANT ALL ON zabbix.* TO 'zabbix'@'localhost';"

	/sbin/service mysqld stop

	touch "$_file_marker"
fi

readonly _cmd="/usr/bin/supervisord -c /etc/supervisord.conf --nodaemon"
readonly _cmd_ctrl="/usr/bin/supervisorctl -c /etc/supervisord.conf"
readonly _shell="/bin/bash"

case "$1" in
	run)
    echo "Running Supervisor ..."
    exec $_cmd
		;;
	stop)
		$_cmd_ctrl stop all
    RETVAL=$?
		;;
	restart)
		$_cmd_ctrl restart all
    RETVAL=$?
		;;
  shell)
    $_shell
    RETVAL=$?
		;;
	status)
		$_cmd_ctrl status all
    RETVAL=$?
		;;
  summary)
		$_cmd_ctrl summary
    RETVAL=$?
		;;
	*)
		echo $"Usage: $0 {start|stop|restart|shell|status|summary}"
		RETVAL=1
esac


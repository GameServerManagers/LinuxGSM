#!/bin/bash
# LGSM fn_install_ts3_mariadb function
# Author: Daniel Gibbs
# Contributor: PhilPhonic
# Website: http://gameservermanagers.com
lgsm_version="271215"

fn_install_ts3db_mariadb(){
	echo ""
	echo "checking if libmariadb2 is installed"
	echo "================================="
	sleep 1
	ldd ${filesdir}/libts3db_mariadb.so | grep "libmariadb.so.2 => not found"
	if [ $? -eq 0 ]; then
		echo "libmariadb2 not installed. Please install it first."
		echo "exiting..."
		exit
	else
		echo "libmariadb2 installed."
	fi
	echo ""
	echo "Configuring ${gamename} Server for MariaDB/MySQL"
	echo "================================="
	sleep 1
	read -p "Enter MariaDB hostname: " mariahostname
	read -p "Enter MariaDB port: " mariaport
	read -p "Enter MariaDB username: " mariausername
	read -p "Enter MariaDB password: " mariapassword
	read -p "Enter MariaDB database name: " mariadbname
	echo "updating config."
	echo "[config]" >> ${servercfgdir}/ts3db_mariadb.ini
	echo "host='${mariahostname}'" >> ${servercfgdir}/ts3db_mariadb.ini
	echo "port='${mariaport}'" >> ${servercfgdir}/ts3db_mariadb.ini
	echo "username='${mariausername}'" >> ${servercfgdir}/ts3db_mariadb.ini
	echo "password='${mariapassword}'" >> ${servercfgdir}/ts3db_mariadb.ini
	echo "database='${mariadbname}'" >> ${servercfgdir}/ts3db_mariadb.ini
	echo "socket=" >> ${servercfgdir}/ts3db_mariadb.ini	
	sed -i "s/dbplugin=ts3db_sqlite3/dbplugin=ts3db_mariadb/g" "${servercfgfullpath}"
	sed -i "s/dbpluginparameter=/dbpluginparameter=ts3db_mariadb.ini/g" "${servercfgfullpath}"
	sed -i "s/dbsqlcreatepath=create_sqlite\//dbsqlcreatepath=create_mariadb\//g" "${servercfgfullpath}"
	echo "================================="
	sleep 1
}

if [ -z "${autoinstall}" ]; then
	echo ""
	while true; do
		read -e -i "n" -p "Do you want to use MariaDB/MySQL instead of sqlite (Database Server including user and database already has to be set up!)? [y/N]" yn
		case $yn in
		[Yy]* ) fn_install_ts3db_mariadb && break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
		esac
	done
else
fn_printwarningnl "./${selfname} auto-install is uses sqlite. For MariaDB/MySQL use ./${selfname} install"
fi

## Get privilege key
echo ""
echo "Getting privilege key"
echo "================================="
sleep 1
echo "IMPORANT! Save these details for later."
sleep 1
cd "${executabledir}"
./ts3server_startscript.sh start inifile=ts3-server.ini
sleep 5
./ts3server_startscript.sh stop

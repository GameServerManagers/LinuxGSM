#!/bin/bash
# LinuxGSM install_ts3db.sh function
# Author: Daniel Gibbs
# Contributor: PhilPhonic
# Website: https://linuxgsm.com
# Description: Installs the database server MariaDB for TeamSpeak 3.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_install_ts3db_mariadb(){
	echo ""
	echo "checking if libmariadb2 is installed"
	echo "================================="
	sleep 1
	ldd ${serverfiles}/libts3db_mariadb.so | grep "libmariadb.so.2 => not found"
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
	read -rp "Enter MariaDB hostname: " mariahostname
	read -rp "Enter MariaDB port: " mariaport
	read -rp "Enter MariaDB username: " mariausername
	read -rp "Enter MariaDB password: " mariapassword
	read -rp "Enter MariaDB database name: " mariadbname
	{
	echo "updating config."
	echo "[config]"
	echo "host='${mariahostname}'"
	echo "port='${mariaport}'"
	echo "username='${mariausername}'"
	echo "password='${mariapassword}'"
	echo "database='${mariadbname}'"
	echo "socket="
	} >> "${servercfgdir}/ts3db_mariadb.ini"
	sed -i "s/dbplugin=ts3db_sqlite3/dbplugin=ts3db_mariadb/g" "${servercfgfullpath}"
	sed -i "s/dbpluginparameter=/dbpluginparameter=ts3db_mariadb.ini/g" "${servercfgfullpath}"
	sed -i "s/dbsqlcreatepath=create_sqlite\//dbsqlcreatepath=create_mariadb\//g" "${servercfgfullpath}"
	echo "================================="
	sleep 1
}

if [ -z "${autoinstall}" ]; then
	echo ""
	if fn_prompt_yn "Do you want to use MariaDB/MySQL instead of sqlite? (DB must be pre-configured)" N; then
		fn_install_ts3db_mariadb
	fi
else
fn_print_warning_nl "./${selfname} auto-install is uses sqlite. For MariaDB/MySQL use ./${selfname} install"
fi

## License
fn_script_log "Accepting ts3server license:  ${executabledir}/LICENSE"
fn_print_information_nl "Accepting TeamSpeak license:"
echo " * ${executabledir}/LICENSE"
sleep 1
touch "${executabledir}/.ts3server_license_accepted"

## Get privilege key
echo ""
echo "Getting privilege key"
echo "================================="
sleep 1
echo "IMPORANT! Save these details for later."
sleep 1
cd "${executabledir}" || exit
./ts3server_startscript.sh start inifile=ts3-server.ini
sleep 5
./ts3server_startscript.sh stop

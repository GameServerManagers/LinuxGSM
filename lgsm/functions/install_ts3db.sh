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
	if [ ! -f "${serverfiles}/libts3db_mariadb.so" ]; then
		echo -e "copying libmariadb.so.2...\c"
		cp "${serverfiles}/redist/libmariadb.so.2" "${serverfiles}"
		local exitcode=$?
		if [ "${exitcode}" == "0" ]; then
			fn_print_ok_eol_nl
			fn_script_log_pass "copying libmariadb.so.2"
		else
			fn_print_fail_eol_nl
			fn_script_log_fatal "copying libmariadb.so.2"
			core_exit.sh
		fi
	fi

	echo ""
	echo "Configuring ${gamename} Server for MariaDB"
	echo "================================="
	sleep 0.5
	read -rp "Enter MariaDB hostname: " mariahostname
	read -rp "Enter MariaDB port: " mariaport
	read -rp "Enter MariaDB username: " mariausername
	read -rp "Enter MariaDB password: " mariapassword
	read -rp "Enter MariaDB database name: " mariadbname
	read -rp "Enter MariaDB socket path:" mariadbsocket
	echo "Updating config."
	{
	echo "[config]"
	echo "host='${mariahostname}'"
	echo "port='${mariaport}'"
	echo "username='${mariausername}'"
	echo "password='${mariapassword}'"
	echo "database='${mariadbname}'"
	echo "socket='${mariadbsocket}'"
	} >> "${servercfgdir}/ts3db_mariadb.ini"
	sed -i "s/dbplugin=ts3db_sqlite3/dbplugin=ts3db_mariadb/g" "${servercfgfullpath}"
	sed -i "s/dbpluginparameter=/dbpluginparameter=ts3db_mariadb.ini/g" "${servercfgfullpath}"
	sed -i "s/dbsqlcreatepath=create_sqlite\//dbsqlcreatepath=create_mariadb\//g" "${servercfgfullpath}"
	echo "================================="
	sleep 0.5
}

echo "Select Database"
echo "================================="
echo ""
if [ -z "${autoinstall}" ]; then
	if fn_prompt_yn "Do you want to use MariaDB instead of sqlite? (DB must be pre-configured)" N; then
		fn_install_ts3db_mariadb
	fi
else
fn_print_information_nl "./${selfname} auto-install is uses sqlite. For MariaDB use ./${selfname} install"
fi

install_eula.sh

## Get privilege key
echo ""
echo "Getting privilege key"
echo "================================="
sleep 0.5
fn_print_information_nl "Save these details for later."
sleep 0.5
cd "${executabledir}" || exit
${executable} start inifile=ts3-server.ini
sleep 5
${executable} stop

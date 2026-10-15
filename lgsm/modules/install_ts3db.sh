#!/bin/bash
# LinuxGSM install_ts3db.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Installs the database server MariaDB for TeamSpeak 3.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_install_ts3db_mariadb() {
	if [ ! -f "${serverfiles}/libts3db_mariadb.so" ]; then
		echo -e "copying libmariadb.so.2...\c"
		cp "${serverfiles}/redist/libmariadb.so.2" "${serverfiles}"
		exitcode=$?
		if [ "${exitcode}" -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "copying libmariadb.so.2"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "copying libmariadb.so.2"
		fi
	fi

	echo -e ""
	echo -e "${bold}${lightyellow}Configure ${gamename} Server for MariaDB${default}"
	fn_messages_separator
	read -rp "Enter MariaDB hostname: " mariahostname
	read -rp "Enter MariaDB port: " mariaport
	read -rp "Enter MariaDB username: " mariausername
	read -rp "Enter MariaDB password: " mariapassword
	read -rp "Enter MariaDB database name: " mariadbname
	read -rp "Enter MariaDB socket path: " mariadbsocket

	{
		echo -e "[config]"
		echo -e "host='${mariahostname}'"
		echo -e "port='${mariaport}'"
		echo -e "username='${mariausername}'"
		echo -e "password='${mariapassword}'"
		echo -e "database='${mariadbname}'"
		echo -e "socket='${mariadbsocket}'"
	} >> "${servercfgdir}/ts3db_mariadb.ini"
	sed -i "s/dbplugin=ts3db_sqlite3/dbplugin=ts3db_mariadb/g" "${servercfgfullpath}"
	sed -i "s/dbpluginparameter=/dbpluginparameter=ts3db_mariadb.ini/g" "${servercfgfullpath}"
	sed -i "s/dbsqlcreatepath=create_sqlite\//dbsqlcreatepath=create_mariadb\//g" "${servercfgfullpath}"
	echo -e "updating ts3db_mariadb.ini."
	fn_sleep_time_1
}

echo -e ""
echo -e "${bold}${lightyellow}Select Database${default}"
fn_messages_separator
if [ -z "${autoinstall}" ]; then
	if fn_prompt_yn "Do you want to use MariaDB instead of sqlite? (MariaDB must be pre-configured)" N; then
		fn_install_ts3db_mariadb
	fi
else
	fn_print_information_nl "./${selfname} auto-install is uses sqlite. For MariaDB use ./${selfname} install"
fi

install_eula.sh

echo -e ""
echo -e "${bold}${lightyellow}Getting Privilege Key${default}"
fn_messages_separator
fn_print_information_nl "Save these details for later."
fn_print_information_nl "Key also saved in:"
echo -e "${serverfiles}/privilege_key.txt"
cd "${executabledir}" || exit
./ts3server_startscript.sh start inifile=ts3-server.ini 2>&1 | tee "${serverfiles}/privilege_key.txt"
fn_sleep_time_5
./ts3server_startscript.sh stop

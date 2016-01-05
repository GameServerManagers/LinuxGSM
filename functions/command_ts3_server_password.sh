#!/bin/bash
# LGSM command_serveradmin_password.sh function
# Author: Daniel Gibbs
# Contributor : UltimateByte
# Website: http://gameservermanagers.com
lgsm_version="050116"

# Description: Changes TS3 serveradmin password

local modulename="TS3 Server Password"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"


fn_serveradmin_password_prompt(){
fn_printwarn "Initiating TS3 serveradmin password change"
sleep 2
echo -en "\n"
echo "Changing telnet ServerQuery password"
while true; do
	read -p "Continue ? [y/n]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) exit;;
	* ) echo "Please answer yes or no.";;
	esac
done

fn_scriptlog "Initiating serveradmin password change"
echo -n "Enter the new password : " ; read newpassword
fn_scriptlog "New serveradmin password chosen"
}


fn_serveradmin_password_set(){
fn_printdots "Applying new password"
sleep 1
fn_scriptlog "Starting routine with new password start option"

./ts3server_startscript.sh start serveradmin_password="${newpassword}" > /dev/null 2>&1

info_ts3status.sh
if [ "${ts3status}" = "Server seems to have died" ]||[ "${ts3status}"	= "No server running (ts3server.pid is missing)" ]; then
	fn_printfailnl "Unable to start ${servername}"
	fn_scriptlog "Unable to start ${servername}"
	echo -e "	Check log files: ${rootdir}/log"
	exit 1
else
	fn_printok "${servername} has set a new serveradmin password"
	echo -en "\n"
	fn_scriptlog "Started ${servername} with new password"
fi
sleep 1
}

# Running functions
check.sh
fn_serveradmin_password_prompt
info_ts3status.sh

if [ "${ts3status}" == "Server is running" ]; then
	command_stop.sh
	fn_serveradmin_password_set
	echo "Server will now restart normally"
	sleep 1
	command_stop.sh
	command_start.sh
else
	fn_serveradmin_password_set
	echo -en "\n"
	command_stop.sh
fi
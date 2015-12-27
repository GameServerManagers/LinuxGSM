#!/bin/bash
# TravisCI Tests
# Server Management Script
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
version="271215"

#### Variables ####

# Notification Email
# (on|off)
emailnotification="on"
email="me@danielgibbs.co.uk"

# Steam login
steamuser="anonymous"
steampass=""

# Start Variables
updateonstart="off"

fn_parms(){
parms=""
}

#### Advanced Variables ####

# Github Branch Select
# Allows for the use of different function files
# from a different repo and/or branch.
githubuser="dgibbs64"
githubrepo="linuxgsm"
githubbranch="$TRAVIS_BRANCH"

# Steam
appid="261140"

# Server Details
servicename="jc2-server"
gamename="Just Cause 2"
engine="avalanche"

# Directories
rootdir="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"
lockselfname=".${servicename}.lock"
filesdir="${rootdir}/serverfiles"
systemdir="${filesdir}"
executabledir="${filesdir}"
executable="./Jcmp-Server"
servercfg="config.lua"
servercfgdir="${filesdir}"
servercfgfullpath="${servercfgdir}/${servercfg}"
servercfgdefault="${servercfgdir}/default_config.lua"
backupdir="${rootdir}/backups"

# Logging
logdays="7"
#gamelogdir="" # No server logs available
scriptlogdir="${rootdir}/log/script"
consolelogdir="${rootdir}/log/console"

scriptlog="${scriptlogdir}/${servicename}-script.log"
consolelog="${consolelogdir}/${servicename}-console.log"
emaillog="${scriptlogdir}/${servicename}-email.log"

scriptlogdate="${scriptlogdir}/${servicename}-script-$(date '+%d-%m-%Y-%H-%M-%S').log"
consolelogdate="${consolelogdir}/${servicename}-console-$(date '+%d-%m-%Y-%H-%M-%S').log"

##### Script #####
# Do not edit

fn_getgithubfile(){
filename=$1
exec=$2
fileurl=${3:-$filename}
filepath="${rootdir}/${filename}"
filedir=$(dirname "${filepath}")
# If the function file is missing, then download
if [ ! -f "${filepath}" ]; then
	if [ ! -d "${filedir}" ]; then
		mkdir "${filedir}"
	fi
	githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${fileurl}"
	echo -e "    fetching ${filename}...\c"
	if [ "$(command -v curl)" ]||[ "$(which curl >/dev/null 2>&1)" ]||[ -f "/usr/bin/curl" ]||[ -f "/bin/curl" ]; then
		:
	else	
		echo -e "\e[0;31mFAIL\e[0m\n"
		echo "Curl is not installed!"
		echo -e ""
		exit
	fi
	curl=$(curl --fail -o "${filepath}" "${githuburl}" 2>&1)
	if [ $? -ne 0 ]; then
		echo -e "\e[0;31mFAIL\e[0m\n"
		echo "${curl}"
		echo -e "${githuburl}\n"
		exit
	else
		echo -e "\e[0;32mOK\e[0m"
	fi	
	if [ "${exec}" ]; then
		chmod +x "${filepath}"
	fi
fi
if [ "${exec}" ]; then
	source "${filepath}"
fi
}

fn_runfunction(){
	fn_getgithubfile "functions/${functionfile}" 1
}

core_functions.sh(){
# Functions are defined in core_functions.sh.
functionfile="${FUNCNAME}"
fn_runfunction
}

core_functions.sh

fn_currentstatus_tmux(){
pid=$(tmux list-sessions 2>&1 | awk '{print $1}' | grep -Ec "^${servicename}:")
if [ "${pid}" != "0" ]; then
	currentstatus="ONLINE"
else
	currentstatus="OFFLINE"	
fi
}

fn_currentstatus_ts3(){
ts3status=$(${executable} status servercfgfullpathfile=${servercfgfullpath})

if [ "${ts3status}" == "Server is running" ]; then
	currentstatus="ONLINE"
else
	currentstatus="OFFLINE"	
fi
}
	
fn_setstatus(){
	fn_currentstatus_tmux
	echo""
	echo "Required status: ${requiredstatus}"
	counter=0
	echo "Current status:  ${currentstatus}"
    while [  "${requiredstatus}" != "${currentstatus}" ]; do
    	counter=$((counter+1))
    	fn_currentstatus_tmux
		echo -ne "New status:  ${currentstatus}\\r"
    	
		if [ "${requiredstatus}" == "ONLINE" ]; then
			(command_start.sh > /dev/null 2>&1)
		else
			(command_stop.sh > /dev/null 2>&1)
		fi
    	if [ "${counter}" -gt "5" ]; then
    		currentstatus="FAIL"
    		echo "Current status:  ${currentstatus}"
    		echo ""
    		echo "Unable to start or stop server."
    		exit 1
    	fi
    done
    echo -ne "New status:  ${currentstatus}\\r"
    echo -e "\n"
    echo "Test starting:"
    echo ""
    sleep 0.5
}

echo "================================="
echo "TravisCI Tests"
echo "Linux Game Server Manager"
echo "by Daniel Gibbs"
echo "http://gameservermanagers.com"
echo "================================="
echo ""
sleep 1
echo "================================="
echo "Server Tests"
echo "Using: ${gamename}"
echo "Testing Branch: $TRAVIS_BRANCH"
echo "================================="
echo ""
sleep 1
mkdir ${rootdir}



echo "1.0 - start - no files"
echo "================================="
echo "Description:"
echo "test script reaction to missing server files."
echo ""
(command_start.sh)
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "1.1 - getopt"
echo "================================="
echo "Description:"
echo "displaying options messages."
echo ""
(core_getopt.sh)
echo ""
echo "Test complete!"
sleep 1
echo ""



echo "2.0 - install"
echo "================================="
echo "Description:"
echo "install ${gamename} server."
fn_autoinstall
echo ""
echo "Test complete!"
sleep 1
echo ""



echo "3.1 - start"
echo "================================="
echo "Description:"
echo "start ${gamename} server."
requiredstatus="OFFLINE"
fn_setstatus
command_start.sh
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "3.2 - start - online"
echo "================================="
echo "Description:"
echo "start ${gamename} server while already running."
requiredstatus="ONLINE"
fn_setstatus
(command_start.sh)
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "3.3 - start - updateonstart"
echo "================================="
echo "Description:"
echo "will update server on start."
requiredstatus="OFFLINE"
fn_setstatus
(
	updateonstart="on"
	command_start.sh
)
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "3.4 - stop"
echo "================================="
echo "Description:"
echo "stop ${gamename} server."
requiredstatus="ONLINE"
fn_setstatus
command_stop.sh
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "3.5 - stop - offline"
echo "================================="
echo "Description:"
echo "stop ${gamename} server while already stopped."
requiredstatus="OFFLINE"
fn_setstatus
(command_stop.sh)
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "3.6 - restart"
echo "================================="
echo "Description:"
echo "restart ${gamename}."
requiredstatus="ONLINE"
fn_setstatus
fn_restart
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "3.7 - restart - offline"
echo "================================="
echo "Description:"
echo "restart ${gamename} while already stopped."
requiredstatus="OFFLINE"
fn_setstatus
fn_restart
echo ""
echo "Test complete!"
sleep 1
echo ""



echo "4.1 - update"
echo "================================="
echo "Description:"
echo "check for updates."
requiredstatus="OFFLINE"
fn_setstatus
update_check.sh
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "4.2 - update  - change buildid"
echo "================================="
echo "Description:"
echo "change the buildid tricking SteamCMD to update."
requiredstatus="OFFLINE"
fn_setstatus
fn_printinfonl "changed buildid to 0."
sed -i 's/[0-9]\+/0/' ${filesdir}/steamapps/appmanifest_${appid}.acf
update_check.sh
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "4.3 - update  - change buildid - online"
echo "================================="
echo "Description:"
echo "change the buildid tricking SteamCMD to update server while already running."
requiredstatus="ONLINE"
fn_setstatus
fn_printinfonl "changed buildid to 0."
sed -i 's/[0-9]\+/0/' ${filesdir}/steamapps/appmanifest_${appid}.acf
update_check.sh
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "4.4 - update  - remove appmanifest file"
echo "================================="
echo "Description:"
echo "removing appmanifest file will cause script to repair."
requiredstatus="OFFLINE"
fn_setstatus
fn_printinfonl "removed appmanifest_${appid}.acf."
rm --verbose "${filesdir}/steamapps/appmanifest_${appid}.acf"
update_check.sh
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "4.5 - force-update"
echo "================================="
echo "Description:"
echo "force-update bypassing update check."
requiredstatus="OFFLINE"
fn_setstatus
update_check.sh
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "4.6 - force-update - online"
echo "================================="
echo "Description:"
echo "force-update bypassing update check server while already running."
requiredstatus="ONLINE"
fn_setstatus
update_check.sh
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "4.7 - validate"
echo "================================="
echo "Description:"
echo "validate server files."
requiredstatus="OFFLINE"
fn_setstatus
command_validate.sh
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "4.8 - validate - online"
echo "================================="
echo "Description:"
echo "validate server files while server while already running."
requiredstatus="ONLINE"
fn_setstatus
command_validate.sh
echo ""
echo "Test complete!"
sleep 1
echo ""



echo "5.1 - monitor - online"
echo "================================="
echo "Description:"
echo "run monitor server while already running."
requiredstatus="ONLINE"
fn_setstatus
(command_monitor.sh)
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "5.2 - monitor - offline - no lockfile"
echo "================================="
echo "Description:"
echo "run monitor while server is offline with no lockfile."
requiredstatus="OFFLINE"
fn_setstatus
(command_monitor.sh)
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "5.3 - monitor - offline - with lockfile"
echo "================================="
echo "Description:"
echo "run monitor while server is offline with no lockfile."
requiredstatus="OFFLINE"
fn_setstatus
fn_printinfonl "creating lockfile."
date > "${rootdir}/${lockselfname}"
(command_monitor.sh)
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "5.4 - monitor - gsquery.py failure"
echo "================================="
echo "Description:"
echo "gsquery.py will fail to query port."
requiredstatus="ONLINE"
fn_setstatus
sed -i 's/[0-9]\+/0/' "${servercfgfullpath}"
(command_monitor.sh)
echo ""
fn_printinfonl "Reseting ${servercfg}."
install_config.sh
echo ""
echo "Test complete!"
sleep 1
echo ""



echo "6.0 - details"
echo "================================="
echo "Description:"
echo "display details."
requiredstatus="ONLINE"
fn_setstatus
command_details.sh
echo ""
echo "Test complete!"
sleep 1
echo ""

echo "================================="
echo "Server Tests - Complete!"
echo "Using: ${gamename}"
echo "================================="
echo ""
requiredstatus="OFFLINE"
fn_setstatus
sleep 1
fn_printinfo "Tidying up directories."
sleep 1
rm -rfv ${serverfiles}
echo "END"


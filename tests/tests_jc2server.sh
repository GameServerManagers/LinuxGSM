#!/bin/bash
# TravisCI Tests
# Server Management Script
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
version="071115"

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

# Steam
appid="261140"

# Server Details
servicename="jc2-server"
gamename="Just Cause 2"
engine="avalanche"

# Directories
rootdir="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
selfname=$(basename $(readlink -f "${BASH_SOURCE[0]}"))
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

fn_runfunction(){
# Functions are downloaded and run with this function
if [ ! -f "${rootdir}/functions/${functionfile}" ]; then
	cd "${rootdir}"
	if [ ! -d "functions" ]; then
		mkdir functions
	fi
	cd functions
	echo -e "    loading ${functionfile}...\c"
	wget -N /dev/null https://raw.githubusercontent.com/dgibbs64/linuxgsm/master/functions/${functionfile} 2>&1 | grep -F HTTP | cut -c45-
	chmod +x "${functionfile}"
	cd "${rootdir}"
fi
source "${rootdir}/functions/${functionfile}"
}

fn_functions(){
# Functions are defined in fn_functions.
functionfile="${FUNCNAME}"
fn_runfunction
}

fn_functions

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
			(fn_start > /dev/null 2>&1)
		else
			(fn_stop > /dev/null 2>&1)
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
echo "================================="
echo ""
sleep 1
mkdir ${rootdir}



echo "1.0 - start - no files"
echo "================================="
echo "Description:"
echo "test script reaction to missing server files."
echo ""
(fn_start)
echo ""
echo "Test complete!"
sleep 1
echo ""
echo "1.1 - getopt"
echo "================================="
echo "Description:"
echo "displaying options messages."
echo ""
(fn_getopt)
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
fn_start
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
(fn_start)
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
	fn_start
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
fn_stop
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
(fn_stop)
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
fn_update_check
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
fn_update_check
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
fn_update_check
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
fn_update_check
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
fn_update_check
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
fn_update_check
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
fn_validate
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
fn_validate
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
(fn_monitor)
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
(fn_monitor)
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
(fn_monitor)
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
(fn_monitor)
echo ""
fn_printinfonl "Reseting ${servercfg}."
fn_install_config
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
fn_details
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

#!/bin/bash
# TravisCI Tests
# Server Management Script
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
version="101716"

#### Advanced Variables ####

# Github Branch Select
# Allows for the use of different function files
# from a different repo and/or branch.
githubuser="dgibbs64"
githubrepo="linuxgsm"
githubbranch="$TRAVIS_BRANCH"

# Steam
appid="261140"

##### Script #####

# Directories
rootdir="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"
lockselfname=".${servicename}.lock"
lgsmdir="${rootdir}/lgsm"
functionsdir="${lgsmdir}/functions"
libdir="${lgsmdir}/lib"
filesdir="${rootdir}/serverfiles"
systemdir="${filesdir}"
executabledir="${filesdir}"
executable="./Jcmp-Server"
servercfg="config.lua"
servercfgdir="${filesdir}"
servercfgfullpath="${servercfgdir}/${servercfg}"
servercfgdefault="${servercfgdir}/default_config.lua"
backupdir="${rootdir}/backups"

# Server Details
servicename="jc2-server"
gamename="Just Cause 2"
engine="avalanche"

# Fetches core_dl for file downloads
fn_fetch_core_dl(){
github_file_url_dir="lgsm/functions"
github_file_url_name="${functionfile}"
filedir="${functionsdir}"
filename="${github_file_url_name}"
githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
# If the file is missing, then download
if [ ! -f "${filedir}/${filename}" ]; then
	if [ ! -d "${filedir}" ]; then
		mkdir -p "${filedir}"
	fi
	echo -e "    fetching ${filename}...\c"
	# Check curl exists and use available path
	curlpaths="$(command -v curl 2>/dev/null) $(which curl >/dev/null 2>&1) /usr/bin/curl /bin/curl /usr/sbin/curl /sbin/curl)"
	for curlcmd in ${curlpaths}
	do
		if [ -x "${curlcmd}" ]; then
			break
		fi
	done
	# If curl exists download file
	if [ "$(basename ${curlcmd})" == "curl" ]; then
		curlfetch=$(${curlcmd} -s --fail -o "${filedir}/${filename}" "${githuburl}" 2>&1)
		if [ $? -ne 0 ]; then
			echo -e "\e[0;31mFAIL\e[0m\n"
			echo "${curlfetch}"
			echo -e "${githuburl}\n"
			exit 1
		else
			echo -e "\e[0;32mOK\e[0m"
		fi
	else
		echo -e "\e[0;31mFAIL\e[0m\n"
		echo "Curl is not installed!"
		echo -e ""
		exit 1
	fi
	chmod +x "${filedir}/${filename}"
fi
source "${filedir}/${filename}"
}

core_dl.sh(){
# Functions are defined in core_functions.sh.
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_functions.sh(){
# Functions are defined in core_functions.sh.
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_dl.sh
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
			./jc2server start > /dev/null 2>&1
		else
			./jc2server stop > /dev/null 2>&1
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

# End of every test will expect the result to either pass or fail
# If the script does not do as intended the whole test will fail
# if excpecting a pass
fn_test_result_pass(){
	if [ $? != 0 ]; then
		fn_print_fail_nl "Test Failed"
		exitcode=1
		core_exit.sh
	else
		fn_print_ok_nl "Test Passed"
		echo ""
	fi
}

# if excpecting a fail
fn_test_result_fail(){
	if [ $? == 0 ]; then
		fn_print_fail_nl "Test Failed"
		exitcode=1
		core_exit.sh
	else
		fn_print_ok_nl "Test Passed"
		echo ""
	fi
}

echo "================================="
echo "TravisCI Tests"
echo "Linux Game Server Manager"
echo "by Daniel Gibbs"
echo "https://gameservermanagers.com"
echo "================================="
echo ""
echo "================================="
echo "Server Tests"
echo "Using: ${gamename}"
echo "Testing Branch: $TRAVIS_BRANCH"
echo "================================="
echo ""

echo "0.0 - Preparing Enviroment"
echo "================================="
echo "Description:"
echo "Preparing Enviroment to run tests"

echo "Downloading jc2server"
wget https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/JustCause2/jc2server
chmod +x jc2server
echo "Create log dir"
mkdir -pv log/script/
echo "Make functions executable"
chmod +x lgsm/functions/*
echo "Enable dev-debug"
./jc2server dev-debug

echo "1.0 - start - no files"
echo "================================="
echo "Description:"
echo "test script reaction to missing server files."
echo ""
echo "Command: ./jc2server start"
./jc2server start
fn_test_result_fail

echo ""
echo "1.1 - getopt"
echo "================================="
echo "Description:"
echo "displaying options messages."
echo ""
echo "Command: ./jc2server"
./jc2server
fn_test_result_pass

echo ""
echo "1.2 - getopt with incorrect args"
echo "================================="
echo "Description:"
echo "displaying options messages."
echo ""
echo "Command: ./jc2server abc123"
./jc2server abc123
fn_test_result_fail

echo ""
echo "2.0 - install"
echo "================================="
echo "Description:"
echo "install Just Cause 2 server."
echo "Command: ./jc2server abc123"
./jc2server auto-install
fn_test_result_pass

echo "================================="
ls -al
echo "================================="
ls -al "${filesdir}"
echo "================================="

echo ""
echo "3.1 - start"
echo "================================="
echo "Description:"
echo "start ${gamename} server."
echo "Command: ./jc2server start"
requiredstatus="OFFLINE"
./jc2server start
fn_test_result_pass

echo ""
echo "3.2 - start - online"
echo "================================="
echo "Description:"
echo "start ${gamename} server while already running."
echo "Command: ./jc2server start"
requiredstatus="ONLINE"
./jc2server start
fn_test_result_fail

echo ""
echo "3.3 - stop"
echo "================================="
echo "Description:"
echo "stop ${gamename} server."
echo "Command: ./jc2server stop"
requiredstatus="ONLINE"
./jc2server stop
fn_test_result_pass

echo ""
echo "3.4 - stop - offline"
echo "================================="
echo "Description:"
echo "stop ${gamename} server while already stopped."
echo "Command: ./jc2server stop"
requiredstatus="OFFLINE"
./jc2server stop
fn_test_result_fail

echo ""
echo "3.6 - restart"
echo "================================="
echo "Description:"
echo "restart ${gamename}."
echo "Command: ./jc2server restart"
requiredstatus="ONLINE"
./jc2server restart
fn_test_result_pass

echo "4.1 - update"
echo "================================="
echo "Description:"
echo "check for updates."
echo "Command: ./jc2server update"
requiredstatus="OFFLINE"
./jc2server update
fn_test_result_pass

echo ""
echo "4.2 - update  - change buildid"
echo "================================="
echo "Description:"
echo "change the buildid tricking SteamCMD to update."
echo "Command: ./jc2server update"
requiredstatus="OFFLINE"
fn_print_info_nl "changed buildid to 0."
sed -i 's/[0-9]\+/0/' "${filesdir}/steamapps/appmanifest_${appid}.acf"
./jc2server update
fn_test_result_pass

echo ""
echo "4.3 - update  - change buildid - online"
echo "================================="
echo "Description:"
echo "change the buildid tricking SteamCMD to update server while already running."
echo "Command: ./jc2server update"
requiredstatus="ONLINE"
fn_print_info_nl "changed buildid to 0."
sed -i 's/[0-9]\+/0/' "${filesdir}/steamapps/appmanifest_${appid}.acf"
./jc2server update
fn_test_result_pass

echo ""
echo "4.4 - update  - remove appmanifest file"
echo "================================="
echo "Description:"
echo "removing appmanifest file will cause script to repair."
echo "Command: ./jc2server update"
requiredstatus="OFFLINE"
fn_print_info_nl "removed appmanifest_${appid}.acf."
rm --verbose "${filesdir}/steamapps/appmanifest_${appid}.acf"
./jc2server update
fn_test_result_pass

echo ""
echo "4.5 - force-update"
echo "================================="
echo "Description:"
echo "force-update bypassing update check."
echo "Command: ./jc2server force-update"
requiredstatus="OFFLINE"
./jc2server force-update
fn_test_result_pass

echo ""
echo "4.7 - validate"
echo "================================="
echo "Description:"
echo "validate server files."
echo "Command: ./jc2server validate"
requiredstatus="OFFLINE"
./jc2server validate
fn_test_result_pass

echo ""
echo "4.8 - validate - online"
echo "================================="
echo "Description:"
echo "validate server files while server while already running."
echo "Command: ./jc2server validate"
requiredstatus="ONLINE"
./jc2server validate
fn_test_result_pass

echo ""
echo "5.1 - monitor - online"
echo "================================="
echo "Description:"
echo "run monitor server while already running."
echo "Command: ./jc2server monitor"
requiredstatus="ONLINE"
./jc2server monitor
fn_test_result_pass

echo ""
echo "5.2 - monitor - offline - with lockfile"
echo "================================="
echo "Description:"
echo "run monitor while server is offline with lockfile."
echo "Command: ./jc2server monitor"
requiredstatus="OFFLINE"
fn_print_info_nl "creating lockfile."
date > "${rootdir}/${lockselfname}"
./jc2server monitor
fn_test_result_fail

echo ""
echo "5.3 - monitor - offline - no lockfile"
echo "================================="
echo "Description:"
echo "run monitor while server is offline with no lockfile."
echo "Command: ./jc2server monitor"
requiredstatus="OFFLINE"
./jc2server monitor
fn_test_result_fail

echo ""
echo "5.4 - monitor - gsquery.py failure"
echo "================================="
echo "Description:"
echo "gsquery.py will fail to query port."
echo "Command: ./jc2server monitor"
requiredstatus="ONLINE"
sed -i 's/[0-9]\+/0/' "${servercfgfullpath}"
./jc2server monitor
fn_test_result_fail
echo ""
fn_print_info_nl "Reseting ${servercfg}."
wget -p "${servercfgfullpath}" https://raw.githubusercontent.com/dgibbs64/linuxgsm/master/JustCause2/cfg/config.lua

echo ""
echo "6.0 - details"
echo "================================="
echo "Description:"
echo "display details."
echo "Command: ./jc2server details"
requiredstatus="ONLINE"
./jc2server details
fn_test_result_pass

echo ""
echo "================================="
echo "Server Tests - Complete!"
echo "Using: ${gamename}"
echo "================================="
echo ""
requiredstatus="OFFLINE"
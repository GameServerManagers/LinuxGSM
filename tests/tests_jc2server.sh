#!/bin/bash
# Project: Game Server Managers - LinuxGSM
# Author: Daniel Gibbs
# License: MIT License, Copyright (c) 2019 Daniel Gibbs
# Purpose: Travis CI Tests: Just Cause 2 | Linux Game Server Management Script
# Contributors: https://github.com/GameServerManagers/LinuxGSM/graphs/contributors
# Documentation: https://docs.linuxgsm.com/
# Website: https://linuxgsm.com

travistest="1"
version="180409"
shortname="jc2"
gameservername="jc2server"
rootdir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
servicename="${gameservername}"
lockselfname=".${servicename}.lock"
lgsmdir="${rootdir}/lgsm"
logdir="${rootdir}/log"
lgsmlogdir="${logdir}/lgsm"
steamcmddir="${rootdir}/steamcmd"
serverfiles="${rootdir}/serverfiles"
functionsdir="${lgsmdir}/functions"
libdir="${lgsmdir}/lib"
tmpdir="${lgsmdir}/tmp"
configdir="${lgsmdir}/config-lgsm"
configdirserver="${configdir}/${gameservername}"
configdirdefault="${lgsmdir}/config-default"

# Allows for testing not on Travis CI
if [ ! -v TRAVIS ]; then
	TRAVIS_BRANCH="develop"
	TRAVIS_BUILD_DIR="${rootdir}"
fi

## GitHub Branch Select
# Allows for the use of different function files
# from a different repo and/or branch.
githubuser="GameServerManagers"
githubrepo="LinuxGSM"
githubbranch="${TRAVIS_BRANCH}"

# Core Function that is required first
core_functions.sh(){
	functionfile="${FUNCNAME}"
	fn_bootstrap_fetch_file_github "lgsm/functions" "core_functions.sh" "${functionsdir}" "chmodx" "run" "noforcedl" "nomd5"
}

# Bootstrap
# Fetches the core functions required before passed off to core_dl.sh

# Fetches core functions
fn_bootstrap_fetch_file(){
	remote_fileurl="${1}"
	local_filedir="${2}"
	local_filename="${3}"
	chmodx="${4:-0}"
	run="${5:-0}"
	forcedl="${6:-0}"
	md5="${7:-0}"
	# download file if missing or download forced
	if [ ! -f "${local_filedir}/${local_filename}" ]||[ "${forcedl}" == "forcedl" ]; then
		if [ ! -d "${local_filedir}" ]; then
			mkdir -p "${local_filedir}"
		fi
		# Defines curl path
		curlpath=$(command -v curl 2>/dev/null)

		# If curl exists download file
		if [ "$(basename "${curlpath}")" == "curl" ]; then
			# trap to remove part downloaded files
			echo -en "    fetching ${local_filename}...\c"
			curlcmd=$(${curlpath} -s --fail -L -o "${local_filedir}/${local_filename}" "${remote_fileurl}" 2>&1)
			local exitcode=$?
			if [ ${exitcode} -ne 0 ]; then
				echo -e "\e[0;31mFAIL\e[0m\n"
				if [ -f "${lgsmlog}" ]; then
					echo -e "${remote_fileurl}" | tee -a "${lgsmlog}"
					echo "${curlcmd}" | tee -a "${lgsmlog}"
				fi
				exit 1
			else
				echo -e "\e[0;32mOK\e[0m"
			fi
		else
			echo "[ FAIL ] Curl is not installed"
			exit 1
		fi
		# make file chmodx if chmodx is set
		if [ "${chmodx}" == "chmodx" ]; then
			chmod +x "${local_filedir}/${local_filename}"
		fi
	fi

	if [ -f "${local_filedir}/${local_filename}" ]; then
		# run file if run is set
		if [ "${run}" == "run" ]; then
			source "${local_filedir}/${local_filename}"
		fi
	fi
}

fn_bootstrap_fetch_file_github(){
	github_file_url_dir="${1}"
	github_file_url_name="${2}"
	githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"

	remote_fileurl="${githuburl}"
	local_filedir="${3}"
	local_filename="${github_file_url_name}"
	chmodx="${4:-0}"
	run="${5:-0}"
	forcedl="${6:-0}"
	md5="${7:-0}"
	# Passes vars to the file download function
	fn_bootstrap_fetch_file "${remote_fileurl}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${md5}"
}

# Installer menu

fn_print_center() {
	columns="$(tput cols)"
	line="$@"
	printf "%*s\n" $(( (${#line} + columns) / 2)) "${line}"
}

fn_print_horizontal(){
	char="${1:-=}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "${char}"
}

# Bash Menu
fn_install_menu_bash() {
	local resultvar=$1
	title=$2
	caption=$3
	options=$4
	fn_print_horizontal
	fn_print_center "${title}"
	fn_print_center "${caption}"
	fn_print_horizontal
	menu_options=()
	while read -r line || [[ -n "${line}" ]]; do
		var=$(echo "${line}" | awk -F "," '{print $2 " - " $3}')
		menu_options+=( "${var}" )
	done <  ${options}
	menu_options+=( "Cancel" )
	select option in "${menu_options[@]}"; do
		if [ -n "${option}" ]&&[ "${option}" != "Cancel" ]; then
			eval "$resultvar=\"${option/%\ */}\""
		fi
		break
	done
}

# Whiptail/Dialog Menu
fn_install_menu_whiptail() {
	local menucmd=$1
	local resultvar=$2
	title=$3
	caption=$4
	options=$5
	height=${6:-40}
	width=${7:-80}
	menuheight=${8:-30}
	IFS=","
	menu_options=()
	while read -r line; do
		key=$(echo "${line}" | awk -F "," '{print $3}')
		val=$(echo "${line}" | awk -F "," '{print $2}')
		menu_options+=( ${val//\"} "${key//\"}" )
	done < "${options}"
	OPTION=$(${menucmd} --title "${title}" --menu "${caption}" "${height}" "${width}" "${menuheight}" "${menu_options[@]}" 3>&1 1>&2 2>&3)
	if [ $? == 0 ]; then
		eval "$resultvar=\"${OPTION}\""
	else
		eval "$resultvar="
	fi
}

# Menu selector
fn_install_menu() {
	local resultvar=$1
	local selection=""
	title=$2
	caption=$3
	options=$4
	# Get menu command
	for menucmd in whiptail dialog bash; do
		if [ -x "$(command -v "${menucmd}")" ]; then
			menucmd=$(command -v "${menucmd}")
			break
		fi
	done
	case "$(basename "${menucmd}")" in
		whiptail|dialog)
			fn_install_menu_whiptail "${menucmd}" selection "${title}" "${caption}" "${options}" 40 80 30;;
		*)
			fn_install_menu_bash selection "${title}" "${caption}" "${options}";;
	esac
	eval "$resultvar=\"${selection}\""
}

# Gets server info from serverlist.csv and puts in to array
fn_server_info(){
	IFS=","
	server_info_array=($(grep -aw "${userinput}" "${serverlist}"))
	shortname="${server_info_array[0]}" # csgo
	gameservername="${server_info_array[1]}" # csgoserver
	gamename="${server_info_array[2]}" # Counter Strike: Global Offensive
}

fn_install_getopt(){
	userinput="empty"
	echo "Usage: $0 [option]"
	echo -e ""
	echo "Installer - Linux Game Server Managers - Version ${version}"
	echo "https://linuxgsm.com"
	echo -e ""
	echo -e "Commands"
	echo -e "install\t\t| Select server to install."
	echo -e "servername\t| e.g $0 csgoserver. Enter name of server/game to install."
	echo -e "list\t\t| List all servers available for install."
	exit
}

fn_install_file(){
	local_filename="${gameservername}"
	if [ -e "${local_filename}" ]; then
		i=2
	while [ -e "${local_filename}-${i}" ] ; do
		let i++
	done
		local_filename="${local_filename}-${i}"
	fi
	cp -R "${selfname}" "${local_filename}"
	sed -i -e "s/shortname=\"core\"/shortname=\"${shortname}\"/g" "${local_filename}"
	sed -i -e "s/gameservername=\"core\"/gameservername=\"${gameservername}\"/g" "${local_filename}"
	echo "Installed ${gamename} server as ${local_filename}"
	echo ""
	if [ ! -d "${serverfiles}" ]; then
		echo "./${local_filename} install"
	else
		echo "Remember to check server ports"
		echo "./${local_filename} details"
	fi
	echo ""
	exit
}

# Prevent from running this script as root.
if [ "$(whoami)" == "root" ]; then
	if [ ! -f "${functionsdir}/core_functions.sh" ]||[ ! -f "${functionsdir}/check_root.sh" ]||[ ! -f "${functionsdir}/core_messages.sh" ]; then
		echo "[ FAIL ] Do NOT run this script as root!"
		exit 1
	else
		core_functions.sh
		check_root.sh
	fi
fi

# LinuxGSM installer mode
if [ "${shortname}" == "core" ]; then
	userinput=$1
	datadir="${tmpdir}/data"
	serverlist="${datadir}/serverlist.csv"

	# Download the latest serverlist. This is the complete list of all supported servers.
	fn_bootstrap_fetch_file_github "lgsm/data" "serverlist.csv" "${datadir}" "nochmodx" "norun" "forcedl" "nomd5"
	if [ ! -f "${serverlist}" ]; then
		echo "[ FAIL ] serverlist.csv could not be loaded."
		exit 1
	fi

	if [ "${userinput}" == "list" ]; then
		{
			awk -F "," '{print $2 "\t" $3}' "${serverlist}"
		} | column -s $'\t' -t | more
		exit
	elif [ "${userinput}" == "install" ]||[ "${userinput}" == "i" ]; then
		fn_install_menu result "LinuxGSM" "Select game to install" "${serverlist}"
		userinput="${result}"
		fn_server_info
		if [ "${result}" == "${gameservername}" ]; then
			fn_install_file
		elif [ "${result}" == "" ]; then
			echo "Install canceled"
		else
			echo "[ FAIL ] menu result does not match gameservername"
			echo "result: ${result}"
			echo "gameservername: ${gameservername}"
		fi
	elif [ -n "${userinput}" ]; then
		fn_server_info
		if [ "${userinput}" == "${gameservername}" ]||[ "${userinput}" == "${gamename}" ]||[ "${userinput}" == "${shortname}" ]; then
			fn_install_file
		else
			echo "[ FAIL ] unknown game server"
		fi
	else
		fn_install_getopt
	fi

# LinuxGSM Server Mode
else
	core_functions.sh

	# Load LinuxGSM configs
	# These are required to get all the default variables for the specific server.
	# Load the default config. If missing download it. If changed reload it.
	if [ ! -f "${configdirdefault}/config-lgsm/${gameservername}/_default.cfg" ]; then
		mkdir -p "${configdirdefault}/config-lgsm/${gameservername}"
		fn_fetch_config "lgsm/config-default/config-lgsm/${gameservername}" "_default.cfg" "${configdirdefault}/config-lgsm/${gameservername}" "_default.cfg" "nochmodx" "norun" "noforcedl" "nomd5"
	fi
	if [ ! -f "${configdirserver}/_default.cfg" ]; then
		mkdir -p "${configdirserver}"
		echo -en "    copying _default.cfg...\c"
		cp -R "${configdirdefault}/config-lgsm/${gameservername}/_default.cfg" "${configdirserver}/_default.cfg"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			echo -e "\e[0;31mFAIL\e[0m\n"
			exit 1
		else
			echo -e "\e[0;32mOK\e[0m"
		fi
	else
		function_file_diff=$(diff -q "${configdirdefault}/config-lgsm/${gameservername}/_default.cfg" "${configdirserver}/_default.cfg")
		if [ "${function_file_diff}" != "" ]; then
			fn_print_warn_nl "_default.cfg has been altered. reloading config."
			echo -en "    copying _default.cfg...\c"
			cp -R "${configdirdefault}/config-lgsm/${gameservername}/_default.cfg" "${configdirserver}/_default.cfg"
			exitcode=$?
			if [ ${exitcode} -ne 0 ]; then
				echo -e "\e[0;31mFAIL\e[0m\n"
				exit 1
			else
				echo -e "\e[0;32mOK\e[0m"
			fi
		fi
	fi
	source "${configdirserver}/_default.cfg"
	# Load the common.cfg config. If missing download it
	if [ ! -f "${configdirserver}/common.cfg" ]; then
		fn_fetch_config "lgsm/config-default/config-lgsm" "common-template.cfg" "${configdirserver}" "common.cfg" "${chmodx}" "nochmodx" "norun" "noforcedl" "nomd5"
		source "${configdirserver}/common.cfg"
	else
		source "${configdirserver}/common.cfg"
	fi
	# Load the instance.cfg config. If missing download it
	if [ ! -f "${configdirserver}/${servicename}.cfg" ]; then
		fn_fetch_config "lgsm/config-default/config-lgsm" "instance-template.cfg" "${configdirserver}" "${servicename}.cfg" "nochmodx" "norun" "noforcedl" "nomd5"
		source "${configdirserver}/${servicename}.cfg"
	else
		source "${configdirserver}/${servicename}.cfg"
	fi
	# Load the linuxgsm.sh in to tmpdir. If missing download it
	if [ ! -f "${tmpdir}/linuxgsm.sh" ]; then
		fn_fetch_file_github "" "linuxgsm.sh" "${tmpdir}" "chmodx" "norun" "noforcedl" "nomd5"
	fi

	# Prevents running of core_exit.sh for Travis.
	if [ -z "${travistest}" ]; then
		getopt=$1
		core_getopt.sh
	fi
fi

fn_currentstatus_tmux(){
	check_status.sh
	if [ "${status}" != "0" ]; then
		currentstatus="ONLINE"
	else
		currentstatus="OFFLINE"
	fi
}

fn_currentstatus_ts3(){
	check_status.sh
	if [ "${status}" != "0" ]; then
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
		echo -en "New status:  ${currentstatus}\\r"

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
	echo -en "New status:  ${currentstatus}\\r"
	echo -e "\n"
	echo "Test starting:"
	echo ""
	sleep 0.5
}

# End of every test will expect the result to either pass or fail
# If the script does not do as intended the whole test will fail
# if expecting a pass
fn_test_result_pass(){
	if [ $? != 0 ]; then
		echo "================================="
		echo "Expected result: PASS"
		echo "Actual result: FAIL"
		fn_print_fail_nl "TEST FAILED"
		exitcode=1
		core_exit.sh
	else
		echo "================================="
		echo "Expected result: PASS"
		echo "Actual result: PASS"
		fn_print_ok_nl "TEST PASSED"
		echo ""
	fi
}

# if expecting a fail
fn_test_result_fail(){
	if [ $? == 0 ]; then
		echo "================================="
		echo "Expected result: FAIL"
		echo "Actual result: PASS"
		fn_print_fail_nl "TEST FAILED"
		exitcode=1
		core_exit.sh
	else
		echo "================================="
		echo "Expected result: FAIL"
		echo "Actual result: FAIL"
		fn_print_ok_nl "TEST PASSED"
		echo ""
	fi
}

# test result n/a
fn_test_result_na(){
	echo "================================="
	echo "Expected result: N/A"
	echo "Actual result: N/A"
	fn_print_fail_nl "TEST N/A"
}

echo "================================="
echo "Travis CI Tests"
echo "Linux Game Server Manager"
echo "by Daniel Gibbs"
echo "Contributors: http://goo.gl/qLmitD"
echo "https://linuxgsm.com"
echo "================================="
echo ""
echo "================================="
echo "Server Tests"
echo "Using: ${gamename}"
echo "Testing Branch: $TRAVIS_BRANCH"
echo "================================="

echo ""
echo "0.0 - Pre-test Tasks"
echo "=================================================================="
echo "Description:"
echo "Create log dir's"
echo ""

echo ""
echo "0.1 - Create log dir's"
echo "================================="
echo ""
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	install_logs.sh
)
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "0.2 - Enable dev-debug"
echo "================================="
echo "Description:"
echo "Enable dev-debug"
echo ""
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_dev_debug.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "1.0 - Pre-install tests"
echo "=================================================================="
echo ""

echo "1.1 - start - no files"
echo "================================="
echo "Description:"
echo "test script reaction to missing server files."
echo "Command: ./${gameservername} start"
echo ""
# Allows for testing not on Travis CI
if [ ! -v TRAVIS ]; then
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_start.sh
)
fn_test_result_fail
else
	echo "Test bypassed"
fi

echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "1.2 - getopt"
echo "================================="
echo "Description:"
echo "displaying options messages."
echo "Command: ./${gameservername}"
echo ""
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	core_getopt.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "1.3 - getopt with incorrect args"
echo "================================="
echo "Description:"
echo "displaying options messages."
echo "Command: ./${gameservername} abc123"
echo ""
getopt="abc123"
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	core_getopt.sh
)
fn_test_result_fail
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "2.0 - Instalation"
echo "=================================================================="

echo ""
echo "2.0 - install"
echo "================================="
echo "Description:"
echo "install ${gamename} server."
echo "Command: ./${gameservername} auto-install"
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	fn_autoinstall
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "3.0 - Start/Stop/Restart Tests"
echo "=================================================================="

echo ""
echo "3.1 - start"
echo "================================="
echo "Description:"
echo "start ${gamename} server."
echo "Command: ./${gameservername} start"
requiredstatus="OFFLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_start.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "3.2 - start - online"
echo "================================="
echo "Description:"
echo "start ${gamename} server while already running."
echo "Command: ./${gameservername} start"
requiredstatus="ONLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_start.sh
)
fn_test_result_fail
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "3.3 - start - updateonstart"
echo "================================="
echo "Description:"
echo "will update server on start."
echo "Command: ./${gameservername} start"
requiredstatus="OFFLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	updateonstart="on";command_start.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "3.4 - stop"
echo "================================="
echo "Description:"
echo "stop ${gamename} server."
echo "Command: ./${gameservername} stop"
requiredstatus="ONLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_stop.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "3.5 - stop - offline"
echo "================================="
echo "Description:"
echo "stop ${gamename} server while already stopped."
echo "Command: ./${gameservername} stop"
requiredstatus="OFFLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_stop.sh
)
fn_test_result_fail
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "3.6 - restart"
echo "================================="
echo "Description:"
echo "restart ${gamename}."
echo "Command: ./${gameservername} restart"
requiredstatus="ONLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_restart.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "3.7 - restart - offline"
echo "================================="
echo "Description:"
echo "restart ${gamename} while already stopped."
echo "Command: ./${gameservername} restart"
requiredstatus="OFFLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_restart.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "4.0 - Update Tests"
echo "=================================================================="

echo ""
echo "4.1 - update"
echo "================================="
echo "Description:"
echo "check for updates."
echo "Command: ./${gameservername} update"
requiredstatus="OFFLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_update.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "4.2 - update  - change buildid"
echo "================================="
echo "Description:"
echo "change the buildid tricking SteamCMD to update."
echo "Command: ./jc2server update"
requiredstatus="OFFLINE"
fn_setstatus
fn_print_info_nl "changed buildid to 0."
sed -i 's/[0-9]\+/0/' "${serverfiles}/steamapps/appmanifest_${appid}.acf"
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_update.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "4.3 - update  - change buildid - online"
echo "================================="
echo "Description:"
echo "change the buildid tricking SteamCMD to update server while already running."
echo "Command: ./jc2server update"
requiredstatus="ONLINE"
fn_setstatus
fn_print_info_nl "changed buildid to 0."
sed -i 's/[0-9]\+/0/' "${serverfiles}/steamapps/appmanifest_${appid}.acf"
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_update.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "4.4 - update  - remove appmanifest file"
echo "================================="
echo "Description:"
echo "removing appmanifest file will cause script to repair."
echo "Command: ./jc2server update"
requiredstatus="OFFLINE"
fn_setstatus
fn_print_info_nl "removed appmanifest_${appid}.acf."
rm --verbose "${serverfiles}/steamapps/appmanifest_${appid}.acf"
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_update.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "4.5 - force-update"
echo "================================="
echo "Description:"
echo "force-update bypassing update check."
echo "Command: ./jc2server force-update"
requiredstatus="OFFLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	forceupdate=1;command_update.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "4.6 - force-update - online"
echo "================================="
echo "Description:"
echo "force-update bypassing update check server while already running."
echo "Command: ./jc2server force-update"
requiredstatus="ONLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	forceupdate=1;command_update.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "4.7 - validate"
echo "================================="
echo "Description:"
echo "validate server files."
echo "Command: ./jc2server validate"
requiredstatus="OFFLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_validate.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "4.8 - validate - online"
echo "================================="
echo "Description:"
echo "validate server files while server already running."
echo ""
echo "Command: ./jc2server validate"
requiredstatus="ONLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_validate.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "Inserting IP address"
echo "================================="
echo "Description:"
echo "Inserting Travis IP in to config."
echo "Allows monitor to work"
travisip=$(ip -o -4 addr|grep eth0|awk '{print $4}'|grep -oe '\([0-9]\{1,3\}\.\?\)\{4\}'|grep -v 127.0.0)
sed -i "/BindIP/c\BindIP                      = \"${travisip}\"," "${serverfiles}/config.lua"
echo "IP: ${travisip}"

echo ""
echo "5.0 - Monitor Tests"
echo "=================================================================="

echo ""
echo "Server IP - Port: ${ip}:${port}"
echo "Server IP - Query Port: ${ip}:${queryport}"

echo ""
echo "5.1 - monitor - online"
echo "================================="
echo "Description:"
echo "run monitor server while already running."
echo "Command: ./${gameservername} monitor"
requiredstatus="ONLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_monitor.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "5.2 - monitor - offline - with lockfile"
echo "================================="
echo "Description:"
echo "run monitor while server is offline with lockfile."
echo "Command: ./${gameservername} monitor"
requiredstatus="OFFLINE"
fn_setstatus
fn_print_info_nl "creating lockfile."
date > "${rootdir}/${lockselfname}"
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_monitor.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "5.3 - monitor - offline - no lockfile"
echo "================================="
echo "Description:"
echo "run monitor while server is offline with no lockfile."
echo "Command: ./${gameservername} monitor"
requiredstatus="OFFLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_monitor.sh
)
fn_test_result_fail
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "5.4 - test-alert"
echo "================================="
echo "Description:"
echo "run monitor while server is offline with no lockfile."
echo "Command: ./${gameservername} test-alert"
requiredstatus="OFFLINE"
fn_setstatus
cp "${servercfgfullpath}" "config.lua"
sed -i 's/[0-9]\+/0/' "${servercfgfullpath}"
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_test_alert.sh
)
fn_test_result_fail
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
fn_print_info_nl "Re-generating ${servercfg}."
cp -v "config.lua" "${servercfgfullpath}"
echo "================================="

echo ""
echo "6.0 - Details Tests"
echo "=================================================================="

echo ""
echo "6.1 - details"
echo "================================="
echo "Description:"
echo "display details."
echo "Command: ./${gameservername} details"
requiredstatus="ONLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_details.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "6.2 - postdetails"
echo "================================="
echo "Description:"
echo "post details."
echo "Command: ./${gameservername} postdetails"
requiredstatus="ONLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_postdetails.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "7.0 - Backup Tests"
echo "=================================================================="

echo ""
echo "7.1 - backup"
echo "================================="
echo "Description:"
echo "run a backup."
echo "Command: ./${gameservername} backup"
requiredstatus="ONLINE"
fn_setstatus
echo "test de-activated until issue #1839 fixed"
#(command_backup.sh)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "8.0 - Development Tools Tests"
echo "=================================================================="

echo ""
echo "8.1 - dev - detect glibc"
echo "================================="
echo "Description:"
echo "detect glibc."
echo "Command: ./${gameservername} detect-glibc"
requiredstatus="ONLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_dev_detect_glibc.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "8.2 - dev - detect ldd"
echo "================================="
echo "Description:"
echo "detect ldd."
echo "Command: ./${gameservername} detect-ldd"
requiredstatus="ONLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_dev_detect_ldd.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "8.3 - dev - detect deps"
echo "================================="
echo "Description:"
echo "detect dependencies."
echo "Command: ./${gameservername} detect-deps"
requiredstatus="ONLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_dev_detect_deps.sh
)
fn_test_result_pass
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "8.4 - dev - query-raw"
echo "================================="
echo "Description:"
echo "raw query output."
echo "Command: ./${gameservername} query-raw"
requiredstatus="ONLINE"
fn_setstatus
(
	exec 5>"${TRAVIS_BUILD_DIR}/dev-debug.log"
	BASH_XTRACEFD="5"
	set -x
	command_dev_query_raw.sh
)
fn_test_result_na
echo "run order"
echo "================="
grep functionfile= "${TRAVIS_BUILD_DIR}/dev-debug.log" | sed 's/functionfile=//g'

echo ""
echo "================================="
echo "Server Tests - Complete!"
echo "Using: ${gamename}"
echo "================================="
requiredstatus="OFFLINE"
fn_setstatus
fn_print_info "Tidying up directories."
rm -rfv "${serverfiles}"
core_exit.sh

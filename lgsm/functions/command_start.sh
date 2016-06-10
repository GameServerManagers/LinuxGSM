#!/bin/bash
# LGSM command_start.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Starts the server.

local modulename="Starting"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_start_teamspeak3(){
	if [ ! -e "${servercfgfullpath}" ]; then
		fn_print_warn_nl "${servercfgfullpath} is missing"
		fn_scriptlog "${servercfgfullpath} is missing"
		echo  "	* Creating blank ${servercfg}"
		fn_scriptlog "Creating blank ${servercfg}"
		sleep 2
		echo  "	* ${servercfg} can remain blank by default."
		fn_scriptlog "${servercfgfullpath} can remain blank by default."
		sleep 2
		echo  "	* ${servercfg} is located in ${servercfgfullpath}."
		fn_scriptlog "${servercfg} is located in ${servercfgfullpath}."
		sleep 5
		touch "${servercfgfullpath}"
	fi

	fn_print_dots "${servername}"
	fn_scriptlog "${servername}"
	sleep 1
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_info_nl "${servername} is already running"
		fn_scriptlog "${servername} is already running"
		exit
	fi

	mv "${scriptlog}" "${scriptlogdate}"
	# Create lock file
	date > "${rootdir}/${lockselfname}"
	cd "${executabledir}"
	if [ "${ts3serverpass}" == "1" ];then
		./ts3server_startscript.sh start serveradmin_password="${newpassword}" inifile="${servercfgfullpath}"
	else
		./ts3server_startscript.sh start inifile="${servercfgfullpath}" > /dev/null 2>&1
	fi
	sleep 1
	check_status.sh
	if [ "${status}" == "0" ]; then
		fn_print_fail_nl "Unable to start ${servername}"
		fn_scriptlog "Unable to start ${servername}"
		echo -e "	Check log files: ${rootdir}/log"
		exit 1
	else
		fn_print_ok_nl "${servername}"
		fn_scriptlog "Started ${servername}"
	fi
}

fn_start_tmux(){
	fn_parms
	fn_print_dots "${servername}"
	fn_scriptlog "${servername}"
	sleep 1

	# Log rotation
	check_status.sh
	if [ "${status}" == "0" ]; then
		fn_scriptlog "Rotating log files"
		if [ "${engine}" == "unreal2" ]; then
			if [ -f "${gamelog}" ]; then
				mv "${gamelog}" "${gamelogdate}"
			fi
		fi
		mv "${scriptlog}" "${scriptlogdate}"
		mv "${consolelog}" "${consolelogdate}"
	fi

	# If server is already running exit
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_info_nl "${servername} is already running"
		fn_scriptlog "${servername} is already running"
		exit
	fi

	# Create lock file
	date > "${rootdir}/${lockselfname}"
	cd "${executabledir}"
	tmux new-session -d -s "${servicename}" "${executable} ${parms}" 2> "${scriptlogdir}/.${servicename}-tmux-error.tmp"

	# tmux pipe-pane not supported in tmux versions < 1.6
	if [ "$(tmux -V|sed "s/tmux //"|sed -n '1 p'|tr -cd '[:digit:]')" -lt "16" ]; then
		echo "Console logging disabled: Tmux => 1.6 required" >> "${consolelog}"
		echo "https://gameservermanagers.com/tmux-upgrade" >> "${consolelog}"
		echo "Currently installed: $(tmux -V)" >> "${consolelog}"

	# Console logging disabled: Bug in tmux 1.8 breaks logging
	elif [ "$(tmux -V|sed "s/tmux //"|sed -n '1 p'|tr -cd '[:digit:]')" -eq "18" ]; then
		echo "Console logging disabled: Bug in tmux 1.8 breaks logging" >> "${consolelog}"
		echo "https://gameservermanagers.com/tmux-upgrade" >> "${consolelog}"
		echo "Currently installed: $(tmux -V)" >> "${consolelog}"

	# Console logging enable or not set
	elif [ "${consolelogging}" == "on" ]||[ -z "${consolelogging}" ]; then
		touch "${consolelog}"
		tmux pipe-pane -o -t "${servicename}" "exec cat >> '${consolelog}'"

	# Console logging disabled
	elif [ "${consolelogging}" == "off" ]; then
		touch "${consolelog}"
		cat "Console logging disabled by user" >> "{consolelog}"
		fn_scriptlog "Console logging disabled by user"
	fi
	sleep 1

	# If the server fails to start
	check_status.sh
	if [ "${status}" == "0" ]; then
		fn_print_fail_nl "Unable to start ${servername}"
		fn_scriptlog "Unable to start ${servername}"
		sleep 1
		if [ -s "${scriptlogdir}/.${servicename}-tmux-error.tmp" ]; then
			fn_print_fail_nl "Unable to start ${servername}: Tmux error:"
			fn_scriptlog "Tmux error"
			echo ""
			echo "Command"
			echo "================================="
			echo "tmux new-session -d -s \"${servicename}\" \"${executable} ${parms}\"" | tee -a "${scriptlog}"
			echo ""
			echo "Error"
			echo "================================="
			cat "${scriptlogdir}/.${servicename}-tmux-error.tmp" | tee -a "${scriptlog}"

			# Detected error https://gameservermanagers.com/issues
			if [ $(grep -c "Operation not permitted" "${scriptlogdir}/.${servicename}-tmux-error.tmp") ]; then
			echo ""
			echo "Fix"
			echo "================================="
				if [ ! $(grep "tty:" /etc/group|grep "$(whoami)") ]; then
					echo "$(whoami) is not part of the tty group."
					fn_scriptlog "$(whoami) is not part of the tty group."
					group=$(grep tty /etc/group)
					echo ""
					echo "	${group}"
					fn_scriptlog "${group}"
					echo ""
					echo "Run the following command with root privileges."
					echo ""
					echo "	usermod -G tty $(whoami)"
					echo ""
					echo "https://gameservermanagers.com/tmux-op-perm"
					fn_scriptlog "https://gameservermanagers.com/tmux-op-perm"
				else
					echo "No known fix currently. Please log an issue."
					fn_scriptlog "No known fix currently. Please log an issue."
					echo "https://gameservermanagers.com/issues"
					fn_scriptlog "https://gameservermanagers.com/issues"
				fi
			fi
		fi
	exit 1
	else
		fn_print_ok "${servername}"
		fn_scriptlog "Started ${servername}"
	fi
	rm "${scriptlogdir}/.${servicename}-tmux-error.tmp"
	echo -en "\n"
}

check.sh
fix.sh
info_config.sh
logs.sh

# Will check for updates is updateonstart is yes
if [ "${status}" == "0" ]; then
	if [ "${updateonstart}" == "yes" ]||[ "${updateonstart}" == "1" ]||[ "${updateonstart}" == "on" ]; then
		update_check.sh
	fi
fi

if [ "${gamename}" == "Teamspeak 3" ]; then
	fn_start_teamspeak3
else
	fn_start_tmux
fi

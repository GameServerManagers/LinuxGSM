#!/bin/bash
# LGSM command_start.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Starts the server.

local commandname="START"
local commandaction="Starting"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_start_teamspeak3(){
	if [ ! -e "${servercfgfullpath}" ]; then
		fn_print_warn_nl "${servercfgfullpath} is missing"
		fn_script_log_warn "${servercfgfullpath} is missing"
		echo  "	* Creating blank ${servercfg}"
		fn_script_log_info "Creating blank ${servercfg}"
		sleep 2
		echo  "	* ${servercfg} can remain blank by default."
		fn_script_log_info "${servercfgfullpath} can remain blank by default."
		sleep 2
		echo  "	* ${servercfg} is located in ${servercfgfullpath}."
		fn_script_log_info "${servercfg} is located in ${servercfgfullpath}."
		sleep 5
		touch "${servercfgfullpath}"
	fi
	sleep 1
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_info_nl "${servername} is already running"
		fn_script_log_error "${servername} is already running"
		core_exit.sh
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
		fn_script_log_fatal "Unable to start ${servername}"
		echo -e "	Check log files: ${rootdir}/log"
		core_exit.sh
	else
		fn_print_ok_nl "${servername}"
		fn_script_log_pass "Started ${servername}"
	fi
}

fn_start_tmux(){
	fn_parms

	# Log rotation
	check_status.sh
	if [ "${status}" == "0" ]; then
		fn_script_log_info "Rotating log files"
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
		fn_script_log_error "${servername} is already running"
		core_exit.sh
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
		fn_script_log_info "Console logging disabled by user"
	fi
	sleep 1

	# If the server fails to start
	check_status.sh
	if [ "${status}" == "0" ]; then
		fn_print_fail_nl "Unable to start ${servername}"
		fn_script_log_fatal "Unable to start ${servername}"
		sleep 1
		if [ -s "${scriptlogdir}/.${servicename}-tmux-error.tmp" ]; then
			fn_print_fail_nl "Unable to start ${servername}: Tmux error:"
			fn_script_log_fatal "Unable to start ${servername}: Tmux error:"
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
					fn_script_log_info "$(whoami) is not part of the tty group."
					group=$(grep tty /etc/group)
					echo ""
					echo "	${group}"
					fn_script_log_info "${group}"
					echo ""
					echo "Run the following command with root privileges."
					echo ""
					echo "	usermod -G tty $(whoami)"
					echo ""
					echo "https://gameservermanagers.com/tmux-op-perm"
					fn_script_log_info "https://gameservermanagers.com/tmux-op-perm"
				else
					echo "No known fix currently. Please log an issue."
					fn_script_log_info "No known fix currently. Please log an issue."
					echo "https://gameservermanagers.com/issues"
					fn_script_log_info "https://gameservermanagers.com/issues"
				fi
			fi
		fi

		core_exit.sh
	else
		fn_print_ok "${servername}"
		fn_script_log_pass "Started ${servername}"
	fi
	rm "${scriptlogdir}/.${servicename}-tmux-error.tmp"
	echo -en "\n"
}

fn_print_dots "${servername}"
sleep 1
check.sh
fix.sh
info_config.sh
logs.sh

# Will check for updates is updateonstart is yes
if [ "${status}" == "0" ]; then
	if [ "${updateonstart}" == "yes" ]||[ "${updateonstart}" == "1" ]||[ "${updateonstart}" == "on" ]; then
		exitbypass=1
		command_update.sh
	fi
fi

if [ "${gamename}" == "TeamSpeak 3" ]; then
	fn_start_teamspeak3
else
	fn_start_tmux
fi
core_exit.sh

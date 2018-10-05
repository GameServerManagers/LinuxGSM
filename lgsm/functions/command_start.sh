#!/bin/bash
# LinuxGSM command_start.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Starts the server.

local commandname="START"
local commandaction="Starting"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_start_teamspeak3(){
	if [ ! -e "${servercfgfullpath}" ]; then
		fn_print_warn_nl "${servercfgfullpath} is missing"
		fn_script_log_warn "${servercfgfullpath} is missing"
		echo  "	* Creating blank ${servercfg}"
		fn_script_log_info "Creating blank ${servercfg}"
		sleep 1
		echo  "	* ${servercfg} can remain blank by default."
		fn_script_log_info "${servercfgfullpath} can remain blank by default."
		sleep 1
		echo  "	* ${servercfg} is located in ${servercfgfullpath}."
		fn_script_log_info "${servercfg} is located in ${servercfgfullpath}."
		sleep 5
		touch "${servercfgfullpath}"
	fi
	sleep 0.5
	if [ -f "${lgsmlog}" ]; then
		mv "${lgsmlog}" "${lgsmlogdate}"
	fi
	# Create lockfile
	date > "${rootdir}/${lockselfname}"
	# Accept license
	if [ ! -f "${executabledir}/.ts3server_license_accepted" ]; then
		fn_script_log "Accepting ts3server license:  ${executabledir}/LICENSE"
		fn_print_info_nl "Accepting TeamSpeak license:"
		echo " * ${executabledir}/LICENSE"
		sleep 3
		touch "${executabledir}/.ts3server_license_accepted"
	fi
	cd "${executabledir}"
	if [ "${ts3serverpass}" == "1" ]; then
		./ts3server_startscript.sh start serveradmin_password="${newpassword}" inifile="${servercfgfullpath}" > /dev/null 2>&1
	else
		./ts3server_startscript.sh start inifile="${servercfgfullpath}" > /dev/null 2>&1
	fi
	sleep 0.5
	check_status.sh
	if [ "${status}" == "0" ]; then
		fn_print_fail_nl "Unable to start ${servername}"
		fn_script_log_fatal "Unable to start ${servername}"
		echo -e "	Check log files: ${logdir}"
		core_exit.sh
	else
		fn_print_ok_nl "${servername}"
		fn_script_log_pass "Started ${servername}"
	fi
}

fn_start_tmux(){
	fn_parms

	# check for tmux size variables
	if [[ "${servercfgtmuxwidth}" =~ ^[0-9]+$ ]]; then
		sessionwidth="${servercfgtmuxwidth}"
	else
		sessionwidth="80"
	fi
	if [[ "${servercfgtmuxheight}" =~ ^[0-9]+$ ]]; then
		sessionheight="${servercfgtmuxheight}"
	else
		sessionheight="23"
	fi

	# Log rotation
	fn_script_log_info "Rotating log files"
	if [ "${engine}" == "unreal2" ]&&[ -f "${gamelog}" ]; then
		mv "${gamelog}" "${gamelogdate}"
	fi
	if [ -f "${lgsmlog}" ]; then
		mv "${lgsmlog}" "${lgsmlogdate}"
	fi
	if [ -f "${consolelog}" ]; then
		mv "${consolelog}" "${consolelogdate}"
	fi

	# Create lockfile
	date > "${rootdir}/${lockselfname}"
	cd "${executabledir}"
	tmux new-session -d -x "${sessionheight}" -y "${sessionwidth}" -s "${servicename}" "${executable} ${parms}" 2> "${lgsmlogdir}/.${servicename}-tmux-error.tmp"

	# Create logfile
	touch "${consolelog}"

	# Get tmux version
	tmuxversion="$(tmux -V | sed "s/tmux //" | sed -n '1 p')"
	# Tmux compiled from source will return "master", therefore ignore it
	if [ "$(tmux -V | sed "s/tmux //" | sed -n '1 p')" == "master" ]; then
		fn_script_log "Tmux version: master (user compiled)"
		echo "Tmux version: master (user compiled)" >> "${consolelog}"
		if [ "${consolelogging}" == "on" ]||[ -z "${consolelogging}" ]; then
			tmux pipe-pane -o -t "${servicename}" "exec cat >> '${consolelog}'"
		fi
	elif [ -n "${tmuxversion}" ]; then
		# Get the digit version of tmux
		tmuxversion="$(tmux -V | sed "s/tmux //" | sed -n '1 p' | tr -cd '[:digit:]')"
		# tmux pipe-pane not supported in tmux versions < 1.6
		if [ "${tmuxversion}" -lt "16" ]; then
			echo "Console logging disabled: Tmux => 1.6 required
			https://linuxgsm.com/tmux-upgrade
			Currently installed: $(tmux -V)" > "${consolelog}"

		# Console logging disabled: Bug in tmux 1.8 breaks logging
		elif [ "${tmuxversion}" -eq "18" ]; then
			echo "Console logging disabled: Bug in tmux 1.8 breaks logging
			https://linuxgsm.com/tmux-upgrade
			Currently installed: $(tmux -V)" > "${consolelog}"
		# Console logging enable or not set
		elif [ "${consolelogging}" == "on" ]||[ -z "${consolelogging}" ]; then
			tmux pipe-pane -o -t "${servicename}" "exec cat >> '${consolelog}'"
		fi
	else
		echo "Unable to detect tmux version" >> "${consolelog}"
		fn_script_log_warn "Unable to detect tmux version"
	fi

# Console logging disabled
if [ "${consolelogging}" == "off" ]; then
	echo "Console logging disabled by user" >> "${consolelog}"
	fn_script_log_info "Console logging disabled by user"
fi
sleep 0.5

	# If the server fails to start
	check_status.sh
	if [ "${status}" == "0" ]; then
		fn_print_fail_nl "Unable to start ${servername}"
		fn_script_log_fatal "Unable to start ${servername}"
		sleep 0.5
		if [ -s "${lgsmlogdir}/.${servicename}-tmux-error.tmp" ]; then
			fn_print_fail_nl "Unable to start ${servername}: Tmux error:"
			fn_script_log_fatal "Unable to start ${servername}: Tmux error:"
			echo ""
			echo "Command"
			echo "================================="
			echo "tmux new-session -d -s \"${servicename}\" \"${executable} ${parms}\"" | tee -a "${lgsmlog}"
			echo ""
			echo "Error"
			echo "================================="
			cat "${lgsmlogdir}/.${servicename}-tmux-error.tmp" | tee -a "${lgsmlog}"

			# Detected error https://linuxgsm.com/support
			if grep -c "Operation not permitted" "${lgsmlogdir}/.${servicename}-tmux-error.tmp"
			then
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
					echo "https://linuxgsm.com/tmux-op-perm"
					fn_script_log_info "https://linuxgsm.com/tmux-op-perm"
				else
					echo "No known fix currently. Please log an issue."
					fn_script_log_info "No known fix currently. Please log an issue."
					echo "https://linuxgsm.com/support"
					fn_script_log_info "https://linuxgsm.com/support"
				fi
			fi
		fi

		core_exit.sh
	else
		fn_print_ok "${servername}"
		fn_script_log_pass "Started ${servername}"
	fi
	rm "${lgsmlogdir}/.${servicename}-tmux-error.tmp"
	echo -en "\n"
}

fn_start_docker(){
	fn_parms
	# Log rotation
	fn_script_log_info "Rotating log files"
	if [ "${engine}" == "unreal2" ]&&[ -f "${gamelog}" ]; then
		mv "${gamelog}" "${gamelogdate}"
	fi
	if [ -f "${lgsmlog}" ]; then
		mv "${lgsmlog}" "${lgsmlogdate}"
	fi
	if [ -f "${consolelog}" ]; then
		mv "${consolelog}" "${consolelogdate}"
	fi
	# Create logfile
	touch "${consolelog}"
	
	# Create lockfile
	date > "${rootdir}/${lockselfname}"
	cd "${executabledir}"
	${executable} ${parms} 2> ${lgsmlogdir}/.${servicename}-tmux-error.tmp
}

fn_print_dots "${servername}"
sleep 0.5
check.sh
# Is the server already started
if [ "${status}" != "0" ]; then # $status comes from check_status.sh, which is run by check.sh for this command
	fn_print_info_nl "${servername} is already running"
	fn_script_log_error "${servername} is already running"
	if [ -z "${exitbypass}" ]; then
		core_exit.sh
	fi
fi
fix.sh
info_config.sh
logs.sh

# Will check for updates is updateonstart is yes
if [ "${updateonstart}" == "yes" ]||[ "${updateonstart}" == "1" ]||[ "${updateonstart}" == "on" ]; then
	exitbypass=1
	unset updateonstart
	command_update.sh
fi

if [ "${gamename}" == "TeamSpeak 3" ]; then
	fn_start_teamspeak3
elif [ "${docker}" == "on" ]; then
	fn_start_docker
else
	fn_start_tmux
fi
core_exit.sh

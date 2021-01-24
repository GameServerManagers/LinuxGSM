#!/bin/bash
# LinuxGSM command_start.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Starts the server.

commandname="START"
commandaction="Starting"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_start_teamspeak3(){
	if [ ! -f "${servercfgfullpath}" ]; then
		fn_print_warn_nl "${servercfgfullpath} is missing"
		fn_script_log_warn "${servercfgfullpath} is missing"
		echo  "	* Creating blank ${servercfg}"
		fn_script_log_info "Creating blank ${servercfg}"
		fn_sleep_time
		echo  "	* ${servercfg} can remain blank by default."
		fn_script_log_info "${servercfgfullpath} can remain blank by default."
		fn_sleep_time
		echo  "	* ${servercfg} is located in ${servercfgfullpath}."
		fn_script_log_info "${servercfg} is located in ${servercfgfullpath}."
		sleep 5
		touch "${servercfgfullpath}"
	fi
	# Accept license.
	if [ ! -f "${executabledir}/.ts3server_license_accepted" ]; then
		install_eula.sh
	fi
	fn_start_tmux
}

# This will allow the Jedi Knight 2 version to be printed in console on start.
# Used to allow update to detect JK2MV server version.
fn_start_jk2(){
	fn_start_tmux
	tmux send -t "${sessionname}" version ENTER > /dev/null 2>&1
}

fn_start_tmux(){
	if [ "${parmsbypass}" ]; then
		parms=""
	else
		fn_parms
	fi
	# check for tmux size variables.
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

	# Log rotation.
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
	date '+%s' > "${lockdir}/${selfname}.lock"
	echo "${version}" >> "${lockdir}/${selfname}.lock"
	echo "${port}" >> "${lockdir}/${selfname}.lock"
	cd "${executabledir}" || exit
	tmux new-session -d -x "${sessionwidth}" -y "${sessionheight}" -s "${sessionname}" "${preexecutable} ${executable} ${parms}" 2> "${lgsmlogdir}/.${selfname}-tmux-error.tmp"

	# Create logfile.
	touch "${consolelog}"

	# Create last start lock file
	date +%s > "${lockdir}/${selfname}-laststart.lock"

	# Get tmux version.
	tmuxversion=$(tmux -V | sed "s/tmux //" | sed -n '1 p')
	# Tmux compiled from source will return "master", therefore ignore it.
	if [ "$(tmux -V | sed "s/tmux //" | sed -n '1 p')" == "master" ]; then
		fn_script_log "Tmux version: master (user compiled)"
		echo -e "Tmux version: master (user compiled)" >> "${consolelog}"
		if [ "${consolelogging}" == "on" ]||[ -z "${consolelogging}" ]; then
			tmux pipe-pane -o -t "${sessionname}" "exec cat >> '${consolelog}'"
		fi
	elif [ "${tmuxversion}" ]; then
		# Get the digit version of tmux.
		tmuxversion=$(tmux -V | sed "s/tmux //" | sed -n '1 p' | tr -cd '[:digit:]')
		# tmux pipe-pane not supported in tmux versions < 1.6.
		if [ "${tmuxversion}" -lt "16" ]; then
			echo -e "Console logging disabled: Tmux => 1.6 required
			https://linuxgsm.com/tmux-upgrade
			Currently installed: $(tmux -V)" > "${consolelog}"

		# Console logging disabled: Bug in tmux 1.8 breaks logging.
		elif [ "${tmuxversion}" -eq "18" ]; then
			echo -e "Console logging disabled: Bug in tmux 1.8 breaks logging
			https://linuxgsm.com/tmux-upgrade
			Currently installed: $(tmux -V)" > "${consolelog}"
		# Console logging enable or not set.
		elif [ "${consolelogging}" == "on" ]||[ -z "${consolelogging}" ]; then
			tmux pipe-pane -o -t "${sessionname}" "exec cat >> '${consolelog}'"
		fi
	else
		echo -e "Unable to detect tmux version" >> "${consolelog}"
		fn_script_log_warn "Unable to detect tmux version"
	fi

	# Console logging disabled.
	if [ "${consolelogging}" == "off" ]; then
		echo -e "Console logging disabled by user" >> "${consolelog}"
		fn_script_log_info "Console logging disabled by user"
	fi
	fn_sleep_time

	# If the server fails to start.
	check_status.sh
	if [ "${status}" == "0" ]; then
		fn_print_fail_nl "Unable to start ${servername}"
		fn_script_log_fatal "Unable to start ${servername}"
		if [ -s "${lgsmlogdir}/.${selfname}-tmux-error.tmp" ]; then
			fn_print_fail_nl "Unable to start ${servername}: Tmux error:"
			fn_script_log_fatal "Unable to start ${servername}: Tmux error:"
			echo -e ""
			echo -e "Command"
			echo -e "================================="
			echo -e "tmux new-session -d -s \"${sessionname}\" \"${preexecutable} ${executable} ${parms}\"" | tee -a "${lgsmlog}"
			echo -e ""
			echo -e "Error"
			echo -e "================================="
			cat "${lgsmlogdir}/.${selfname}-tmux-error.tmp" | tee -a "${lgsmlog}"

			# Detected error https://linuxgsm.com/support
			if grep -c "Operation not permitted" "${lgsmlogdir}/.${selfname}-tmux-error.tmp"
			then
			echo -e ""
			echo -e "Fix"
			echo -e "================================="
				if ! grep "tty:" /etc/group | grep "$(whoami)"; then
					echo -e "$(whoami) is not part of the tty group."
					fn_script_log_info "$(whoami) is not part of the tty group."
					group=$(grep tty /etc/group)
					echo -e ""
					echo -e "	${group}"
					fn_script_log_info "${group}"
					echo -e ""
					echo -e "Run the following command with root privileges."
					echo -e ""
					echo -e "	usermod -G tty $(whoami)"
					echo -e ""
					echo -e "https://linuxgsm.com/tmux-op-perm"
					fn_script_log_info "https://linuxgsm.com/tmux-op-perm"
				else
					echo -e "No known fix currently. Please log an issue."
					fn_script_log_info "No known fix currently. Please log an issue."
					echo -e "https://linuxgsm.com/support"
					fn_script_log_info "https://linuxgsm.com/support"
				fi
			fi
		fi
		core_exit.sh
	else
		fn_print_ok "${servername}"
		fn_script_log_pass "Started ${servername}"
	fi
	rm "${lgsmlogdir:?}/.${selfname}-tmux-error.tmp"
	echo -en "\n"
}

check.sh

# Is the server already started.
# $status comes from check_status.sh, which is run by check.sh for this command
if [ "${status}" != "0" ]; then
	fn_print_dots "${servername}"
	fn_print_info_nl "${servername} is already running"
	fn_script_log_error "${servername} is already running"
	if [ -z "${exitbypass}" ]; then
		core_exit.sh
	fi
fi
if [ -z "${fixbypass}" ]; then
	fix.sh
fi
info_config.sh
core_logs.sh

# Will check for updates is updateonstart is yes.
if [ "${updateonstart}" == "yes" ]||[ "${updateonstart}" == "1" ]||[ "${updateonstart}" == "on" ]; then
	exitbypass=1
	unset updateonstart
	command_update.sh
	fn_firstcommand_reset
fi

fn_print_dots "${servername}"

if [ "${shortname}" == "ts3" ]; then
	fn_start_teamspeak3
elif [ "${shortname}" == "jk2" ]; then
	fn_start_jk2
else
	fn_start_tmux
fi

core_exit.sh

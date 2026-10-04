#!/bin/bash
# LinuxGSM command_start.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Starts the server.

commandname="START"
commandaction="Starting"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
addtimestamp="gawk '{ print strftime(\\\"[$logtimestampformat]\\\"), \\\$0 }'"
fn_firstcommand_set

# This will allow the Jedi Knight 2 version to be printed in console on start.
# Used to allow update to detect JK2MV server version.
fn_start_jk2() {
	fn_start_tmux
	TERM=screen tmux -L "${socketname}" end -t "${sessionname}" version ENTER > /dev/null 2>&1
}

# Hytale: after the server boots, check whether it logged in. If it didn't (no saved login, or one that
# can't be decrypted, e.g. created on another machine or container), start the login, then show the
# login URL and send it as an alert, so it can be approved without opening the console.
fn_start_hyt_login() {
	hytloginurl=""
	local hytloginsent="${hytloginpending}"
	for _ in {1..120}; do
		hytloginurl=$(grep -a -oE "https://[^ ]*device/verify\?user_code=[A-Za-z0-9]+" "${consolelog}" 2> /dev/null | tail -1)
		if [ -n "${hytloginurl}" ]; then
			break
		fi
		# Logged in with the saved server login: nothing to do.
		if grep -a -q "Authentication successful" "${consolelog}" 2> /dev/null; then
			fn_script_log_info "Hytale server login restored from saved credentials"
			return
		fi
		# Booted without a usable login: ask the server to start one.
		if [ "${hytloginsent}" != "1" ] && grep -a -q "Hytale Server Booted" "${consolelog}" 2> /dev/null && grep -a -q "No server tokens configured" "${consolelog}" 2> /dev/null; then
			fn_script_log_info "Hytale server has no usable saved login, starting login"
			TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" "auth login device" ENTER
			hytloginsent="1"
		fi
		sleep 1
	done
	echo -e ""
	if [ -n "${hytloginurl}" ]; then
		echo -e "${bold}${lightyellow}Hytale server login required${default}"
		echo -e "Open the URL below in a browser and log in with a Hytale account that owns the game."
		echo -e "The code expires in 10 minutes. This is only needed once; the server saves the login."
		echo -e "${hytloginurl}"
		fn_script_log_info "Hytale server login required: ${hytloginurl}"
		alert="hytale-login"
		alert.sh
	else
		fn_print_warn_nl "Hytale server login required, but no login URL was found in the console yet"
		echo -e "* Run ./${selfname} send \"/auth login device\" and approve the code shown in the console."
		fn_script_log_warn "Hytale server login required, but no login URL was found in the console"
	fi
}

fn_start_tmux() {
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
	if [ "${engine}" == "unreal2" ] && [ -f "${gamelog}" ]; then
		mv "${gamelog}" "${gamelogdate}"
	fi
	if [ -f "${lgsmlog}" ]; then
		mv "${lgsmlog}" "${lgsmlogdate}"
	fi
	if [ -f "${consolelog}" ]; then
		mv "${consolelog}" "${consolelogdate}"
	fi

	# Create a starting lockfile that only exists while the start command is running.
	date '+%s' > "${lockdir:?}/${selfname}-starting.lock"

	fn_reload_startparameters

	# Hytale: with no saved server login file, have the server start its login (OAuth device code) on boot.
	# A saved login that can't be used is handled after boot by fn_start_hyt_login.
	if [ "${shortname}" == "hyt" ] && [ ! -f "${systemdir}/auth.enc" ]; then
		startparameters="${startparameters} --boot-command 'auth login device'"
		hytloginpending="1"
	fi

	# Create uid to ensure unique tmux socket name.
	if [ ! -f "${datadir}/${selfname}.uid" ]; then
		check_status.sh
		if [ "${status}" != "0" ]; then
			# stop running server (if running) to prevent lingering tmux sessions.
			exitbypass=1
			command_stop.sh
		fi
		uid=$(date '+%s' | sha1sum | head -c 8)
		echo "${uid}" > "${datadir}/${selfname}.uid"
		socketname="${sessionname}-$(cat "${datadir}/${selfname}.uid")"
	fi

	if [ "${shortname}" == "av" ]; then
		cd "${systemdir}" || exit
	else
		cd "${executabledir}" || exit
	fi

	TERM=screen tmux -L "${socketname}" new-session -d -x "${sessionwidth}" -y "${sessionheight}" -s "${sessionname}" "${preexecutable} ${executable} ${startparameters}" 2> "${lgsmlogdir}/.${selfname}-tmux-error.tmp"

	# Create logfile.
	touch "${consolelog}"

	# tmux compiled from source will return "master", therefore ignore it.
	if [ "${tmuxversion}" == "master" ]; then
		fn_script_log "tmux version: master (user compiled)"
		echo -e "tmux version: master (user compiled)" >> "${consolelog}"
	fi

	# Enable console logging.
	if [ "${consolelogging}" == "on" ] || [ -z "${consolelogging}" ]; then
		# timestamp will break mcb update check.
		if [ "${logtimestamp}" == "on" ] && [ "${shortname}" != "mcb" ]; then
			TERM=screen tmux -L "${socketname}" pipe-pane -o -t "${sessionname}" "exec bash -c \"cat | $addtimestamp\" >> '${consolelog}'"
		else
			TERM=screen tmux -L "${socketname}" pipe-pane -o -t "${sessionname}" "exec cat >> '${consolelog}'"
		fi
	else
		echo -e "Console logging disabled in settings" >> "${consolelog}"
		fn_script_log_info "Console logging disabled in settings"
	fi

	fn_sleep_time_1

	# If the server fails to start.
	check_status.sh
	if [ "${status}" == "0" ]; then
		fn_print_fail_nl "Unable to start ${servername}"
		fn_script_log_fail "Unable to start ${servername}"
		if [ -s "${lgsmlogdir}/.${selfname}-tmux-error.tmp" ]; then
			fn_print_fail_nl "Unable to start ${servername}: tmux error:"
			fn_script_log_fail "Unable to start ${servername}: tmux error"
			echo -e ""
			echo -e "Command"
			fn_messages_separator
			echo -e "tmux -L \"${sessionname}\" new-session -d -s \"${sessionname}\" \"${preexecutable} ${executable} ${startparameters}\"" | tee -a "${lgsmlog}"
			echo -e ""
			echo -e "Error"
			fn_messages_separator
			tee -a "${lgsmlog}" < "${lgsmlogdir}/.${selfname}-tmux-error.tmp"

			# Detected error https://linuxgsm.com/support
			if grep -c "Operation not permitted" "${lgsmlogdir}/.${selfname}-tmux-error.tmp"; then
				echo -e ""
				echo -e "Fix"
				fn_messages_separator
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
					echo -e "${italic}https://linuxgsm.com/tmux-op-perm"
					fn_script_log_info "https://linuxgsm.com/tmux-op-perm"
				else
					echo -e "No known fix currently. Please log an issue."
					fn_script_log_info "No known fix currently. Please log an issue."
					echo -e "${italic}https://linuxgsm.com/support"
					fn_script_log_info "https://linuxgsm.com/support"
				fi
			fi
		fi
		# Remove starting lockfile when command ends.
		rm -f "${lockdir:?}/${selfname}-starting.lock"
		core_exit.sh
	else
		# Create start lockfile that exists only when the server is running.
		date '+%s' > "${lockdir:?}/${selfname}-started.lock"
		echo "${version}" >> "${lockdir}/${selfname}-started.lock"
		echo "${port}" >> "${lockdir}/${selfname}-started.lock"
		fn_print_ok "${servername}"
		fn_script_log_pass "Started ${servername}"

		# Create last started Lockfile.
		date +%s > "${lockdir}/${selfname}-last-started.lock"

		fn_print_ok "${servername}"
		fn_script_log_pass "Started ${servername}"
		if [ "${statusalert}" == "on" ] && [ "${firstcommandname}" == "START" ]; then
			alert="started"
			alert.sh
		elif [ "${statusalert}" == "on" ] && [ "${firstcommandname}" == "RESTART" ]; then
			alert="restarted"
			alert.sh
		fi
		if [ "${shortname}" == "hyt" ]; then
			fn_start_hyt_login
		fi
	fi
	rm -f "${lgsmlogdir:?}/.${selfname}-tmux-error.tmp" 2> /dev/null
	echo -en "\n"
}

# If user ran the start command monitor will become enabled.
if [ "${firstcommandname}" == "START" ] || [ "${firstcommandname}" == "RESTART" ]; then
	date '+%s' > "${lockdir:?}/${selfname}-monitoring.lock"
fi

fn_print_dots ""
check.sh

# If the server already started dont start again.
if [ "${status}" != "0" ]; then
	fn_print_dots "${servername}"
	fn_print_skip_nl "${servername} is already running"
	fn_script_log_error "${servername} is already running"
	if [ -z "${exitbypass}" ]; then
		# Remove starting lockfile when command ends.
		rm -f "${lockdir:?}/${selfname}-starting.lock"
		core_exit.sh
	fi
fi

fix.sh
info_game.sh
core_logs.sh

# Will check for updates if updateonstart is yes.
if [ "${updateonstart}" == "yes" ] || [ "${updateonstart}" == "1" ] || [ "${updateonstart}" == "on" ]; then
	exitbypass=1
	unset updateonstart
	command_update.sh
	fn_firstcommand_reset
fi

fn_print_dots "${servername}"
if [ "${shortname}" == "jk2" ]; then
	fn_start_jk2
else
	fn_start_tmux
fi

# Remove starting lockfile when command ends.
rm -f "${lockdir:?}/${selfname}-starting.lock"
core_exit.sh

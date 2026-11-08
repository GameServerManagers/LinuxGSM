#!/bin/bash
# LinuxGSM check_update_lock.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Stops an update or validate from running while another one is running.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

updatinglock="${lockdir}/updating.lock"

fn_update_lock_create() {
	(
		set -o noclobber
		echo "$$" > "${updatinglock}"
	) 2> /dev/null
}

# Checks the PID in the lockfile is running and started before the lockfile was written.
fn_update_lock_running() {
	local lockpid="${1}"
	local lockage processage
	if [ -z "${lockpid}" ] || ! kill -0 "${lockpid}" 2> /dev/null; then
		return 1
	fi
	lockage="$(($(date '+%s') - $(stat -c %Y "${updatinglock}" 2> /dev/null || echo 0)))"
	processage="$(ps -o etimes= -p "${lockpid}" 2> /dev/null | tr -d ' ')"
	[ -n "${processage}" ] && [ "$((processage + 2))" -ge "${lockage}" ]
}

if ! fn_update_lock_create; then
	updatelockpid="$(cat "${updatinglock}" 2> /dev/null)"
	if [ -z "${updatelockpid}" ]; then
		sleep 1
		updatelockpid="$(cat "${updatinglock}" 2> /dev/null)"
	fi
	if [ "${updatelockpid}" == "$$" ] && [ -n "${updatelocklevel}" ]; then
		return
	fi
	if [ "${updatelockpid}" == "$$" ] || ! fn_update_lock_running "${updatelockpid}"; then
		fn_script_log_warn "Checking update: Removing stale lockfile from PID ${updatelockpid:-unknown}"
		rm -f "${updatinglock:?}"
		fn_update_lock_create
	fi
fi

updatelockpid="$(cat "${updatinglock}" 2> /dev/null)"
if [ "${updatelockpid}" != "$$" ]; then
	fn_print_dots "Checking update"
	fn_print_checking_eol
	fn_print_info "Checking update: Update is already running (PID ${updatelockpid})"
	fn_print_info_eol_nl
	fn_script_log_info "Checking update: Update is already running (PID ${updatelockpid})"
	# shellcheck disable=SC2034 # Used by core_exit.sh.
	exitcode=0
	unset exitbypass
	core_exit.sh
fi
updatelocklevel="${BASH_SUBSHELL}"

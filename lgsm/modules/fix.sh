#!/bin/bash
# LinuxGSM fix.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Overall module for managing fixes.
# Runs modules that will fix an issue.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Messages that are displayed for some fixes.
fn_fix_msg_start() {
	fn_print_dots "Applying ${fixname} fix: ${gamename}"
	fn_print_info "Applying ${fixname} fix: ${gamename}"
	fn_script_log_info "Applying ${fixname} fix: ${gamename}"
}

fn_fix_msg_start_nl() {
	fn_print_dots "Applying ${fixname} fix: ${gamename}"
	fn_print_info_nl "Applying ${fixname} fix: ${gamename}"
	fn_script_log_info "Applying ${fixname} fix: ${gamename}"
}

fn_fix_msg_end() {
	if [ $? != 0 ]; then
		fn_print_error_nl "Applying ${fixname} fix: ${gamename}"
		fn_script_log_error "Applying ${fixname} fix: ${gamename}"
	else
		fn_print_ok_nl "Applying ${fixname} fix: ${gamename}"
		fn_script_log_pass "Applying ${fixname} fix: ${gamename}"
	fi
}

fn_exists_fix() {
	local short="${1:?}"

	if [ "$(type -t "fix_${short}.sh")" == 'function' ]; then
		return 0
	else
		return 1
	fi
}

fn_apply_fix() {
	local phase_message="${1:?}"
	local short="${2:?}"

	if fn_exists_fix "${short}"; then
		"fix_${short}.sh"
	else
		fn_print_error_nl "${shortname} is marked to apply pre start fix but there is no fix registered"
	fi
}

apply_pre_start_fix=(arma3 armar ark av bt bo csgo cmw dst hw ins kf nmrih onset pvr ro rust rw samp sdtd sfc sof2 squad st tf2 terraria ts3 mcb mta unt vh wurm zmr)
apply_post_install_fix=(av kf kf2 ro ut2k4 ut ut3)

# validate registered fixes for safe development
for fix in "${apply_pre_start_fix[@]}" "${apply_post_install_fix[@]}"; do
	if ! fn_exists_fix "${fix}"; then
		fn_print_fail_nl "fix_${fix}.sh is registered but doesn't exist. Typo or did you miss to modify core_modules.sh?"
		exitcode=1
		core_exit.sh
	fi
done

# Fixes that are run on start.
if [ "${commandname}" != "INSTALL" ] && [ -z "${fixbypass}" ]; then
	if [ "${appid}" ]; then
		fix_steamcmd.sh
	fi

	if grep -qEe "(^|\s)${shortname}(\s|$)" <<< "${apply_pre_start_fix[@]}"; then
		fn_apply_fix "pre start" "${shortname}"
	fi
fi

# Fixes that are run on install only.
if [ "${commandname}" == "INSTALL" ]; then
	if grep -qEe "(^|\s)${shortname}(\s|$)" <<< "${apply_post_install_fix[@]}"; then
		echo -e ""
		echo -e "${lightyellow}Applying Post-Install Fixes${default}"
		fn_messages_separator
		postinstall=1
		fn_apply_fix "post install" "${shortname}"
	fi
fi

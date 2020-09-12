#!/bin/bash
# LinuxGSM fix.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Overall function for managing fixes.
# Runs functions that will fix an issue.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Messages that are displayed for some fixes.
fn_fix_msg_start(){
	fn_print_dots "Applying ${fixname} fix: ${gamename}"
	fn_print_info "Applying ${fixname} fix: ${gamename}"
	fn_script_log_info "Applying ${fixname} fix: ${gamename}"
}

fn_fix_msg_start_nl(){
	fn_print_dots "Applying ${fixname} fix: ${gamename}"
	fn_print_info "Applying ${fixname} fix: ${gamename}"
	fn_script_log_info "Applying ${fixname} fix: ${gamename}"
}

fn_fix_msg_end(){
	if [ $? != 0 ]; then
		fn_print_error_nl "Applying ${fixname} fix: ${gamename}"
		fn_script_log_error "Applying ${fixname} fix: ${gamename}"
	else
		fn_print_ok_nl "Applying ${fixname} fix: ${gamename}"
		fn_script_log_pass "Applying ${fixname} fix: ${gamename}"
	fi
}

# Fixes that are run on start.
if [ "${commandname}" != "INSTALL" ]&&[ -z "${fixbypass}" ]; then
	if [ "${appid}" ]; then
		fix_steamcmd.sh
	fi

	if  [ "${shortname}" == "arma3" ]; then
		fix_arma3.sh
	elif [ "${shortname}" == "ark" ]; then
		fix_ark.sh
	elif [ "${shortname}" == "csgo" ]; then
		fix_csgo.sh
	elif [ "${shortname}" == "cmw" ]; then
		fix_cmw.sh
	elif [ "${shortname}" == "dst" ]; then
		fix_dst.sh
	elif [ "${shortname}" == "ges" ]; then
		fix_ges.sh
	elif [ "${shortname}" == "hw" ]; then
		fix_hw.sh
	elif [ "${shortname}" == "ins" ]; then
		fix_ins.sh
	elif [ "${shortname}" == "nmrih" ]; then
		fix_nmrih.sh
	elif [ "${shortname}" == "onset" ]; then
		fix_onset.sh
	elif [ "${shortname}" == "rust" ]; then
		fix_rust.sh
	elif [ "${shortname}" == "rw" ]; then
		fix_rw.sh
	elif [ "${shortname}" == "sdtd" ]; then
		fix_sdtd.sh
	elif [ "${shortname}" == "sfc" ]; then
		fix_sfc.sh
	elif [ "${shortname}" == "sof2" ]; then
		fix_sof2.sh
	elif [ "${shortname}" == "ss3" ]; then
		fix_ss3.sh
	elif [ "${shortname}" == "tf2" ]; then
		fix_tf2.sh
	elif [ "${shortname}" == "terraria" ]; then
		fix_terraria.sh
	elif [ "${shortname}" == "ts3" ]; then
		fix_ts3.sh
	elif [ "${shortname}" == "tu" ]; then
		fix_tu.sh
	elif [ "${shortname}" == "mcb" ]; then
		fix_mcb.sh
	elif [ "${shortname}" == "mta" ]; then
		fix_mta.sh
	elif [ "${shortname}" == "unt" ]; then
		fix_unt.sh
	elif [ "${shortname}" == "vh" ]; then
		fix_vh.sh
	elif [ "${shortname}" == "wurm" ]; then
		fix_wurm.sh
	elif [ "${shortname}" == "zmr" ]; then
		fix_zmr.sh
	fi
fi

# Fixes that are run on install only.
if [ "${commandname}" == "INSTALL" ]; then
		if [ "${shortname}" == "av" ]||[ "${shortname}" == "cmw" ]||[ "${shortname}" == "kf" ]||[ "${shortname}" == "kf2" ]||[ "${shortname}" == "onset" ]||[ "${shortname}" == "ro" ]||[ "${shortname}" == "ut2k4" ]||[ "${shortname}" == "ut" ]||[ "${shortname}" == "ut3" ]; then
			echo -e ""
			echo -e "Applying Post-Install Fixes"
			echo -e "================================="
			fn_sleep_time
			postinstall=1
			if [ "${shortname}" == "av" ]; then
				fix_av.sh
			elif [ "${shortname}" == "kf" ]; then
				fix_kf.sh
			elif [ "${shortname}" == "kf2" ]; then
				fix_kf2.sh
			elif [ "${shortname}" == "ro" ]; then
				fix_ro.sh
			elif [ "${shortname}" == "ut2k4" ]; then
				fix_ut2k4.sh
			elif [ "${shortname}" == "ut" ]; then
				fix_ut.sh
			elif [ "${shortname}" == "ut3" ]; then
				fix_ut3.sh
			else
				fn_print_information_nl "No fixes required."
			fi
		fi
fi

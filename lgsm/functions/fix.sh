#!/bin/bash
# LinuxGSM fix.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Overall function for managing fixes.
# Runs functions that will fix an issue.

local commandname="FIX"
local commandaction="Fix"

# Messages that are displayed for some fixes
fn_fix_msg_start(){
	fn_print_dots "Applying ${fixname} fix: ${gamename}"
	sleep 0.5
	fn_print_info "Applying ${fixname} fix: ${gamename}"
	fn_script_log_info "Applying ${fixname} fix: ${gamename}"
	sleep 0.5
}

fn_fix_msg_start_nl(){
	fn_print_dots "Applying ${fixname} fix: ${gamename}"
	sleep 0.5
	fn_print_info "Applying ${fixname} fix: ${gamename}"
	fn_script_log_info "Applying ${fixname} fix: ${gamename}"
	sleep 0.5
}

fn_fix_msg_end(){
	if [ $? -ne 0 ]; then
		fn_print_error_nl "Applying ${fixname} fix: ${gamename}"
		fn_script_log_error "Applying ${fixname} fix: ${gamename}"
		exitcode=2
	else
		fn_print_ok_nl "Applying ${fixname} fix: ${gamename}"
		fn_script_log_pass "Applying ${fixname} fix: ${gamename}"
	fi
}

# Fixes that are run on start
if [ "${function_selfname}" != "command_install.sh" ]; then
	if [ -n "${appid}" ]; then
		fix_steamcmd.sh
	fi

	if  [ "${gamename}" == "ARMA 3" ]; then
		fix_arma3.sh
	elif [ "${shortname}" == "ark" ]; then
		fix_ark.sh
	elif [ "${gamename}" == "Counter-Strike: Global Offensive" ]; then
		fix_csgo.sh
	elif [ "${gamename}" == "Don't Starve Together" ]; then
		fix_dst.sh
	elif [ "${gamename}" == "GoldenEye: Source" ]; then
		fix_ges.sh
	elif [ "${gamename}" == "Insurgency" ]; then
		fix_ins.sh
	elif [ "${gamename}" == "Rust" ]; then
		fix_rust.sh
	elif [ "${shortname}" == "rw" ]; then
		fix_rw.sh
	elif [ "${shortname}" == "ss3" ]; then
		fix_ss3.sh
	elif [ "${gamename}" == "Multi Theft Auto" ]; then
		fix_mta.sh
	fi
fi

# Fixes that are run on install only.
if [ "${function_selfname}" == "command_install.sh" ]; then
		echo ""
		echo "Applying ${gamename} Server Fixes"
		echo "================================="
		sleep 0.5
		if [ "${gamename}" == "Killing Floor" ]; then
			fix_kf.sh
		elif [ "${gamename}" == "Killing Floor 2" ]; then
			fix_kf2.sh
		elif [ "${gamename}" == "Red Orchestra: Ostfront 41-45" ]; then
			fix_ro.sh
		elif [ "${gamename}" == "Unreal Tournament 2004" ]; then
			fix_ut2k4.sh
		elif [ "${gamename}" == "Unreal Tournament" ]; then
			fix_ut.sh
		elif [ "${gamename}" == "Unreal Tournament 3" ]; then
			fix_ut3.sh
		elif [ "${shortname}" == "wurm" ]; then
			fix_wurm.sh
		else
			fn_print_information_nl "No fixes required."
		fi

fi

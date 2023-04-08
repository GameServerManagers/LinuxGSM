#!/bin/bash
# LinuxGSM core_functions.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Defines all functions to allow download and execution of functions using fn_fetch_function.
# This function is called first before any other function. Without this file other functions will not load.

module_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

modulesversion="v23.2.0"

# Core

core_dl.sh() {
	functionfile="${FUNCNAME[0]}"
	if [ "$(type fn_fetch_core_dl 2> /dev/null)" ]; then
		fn_fetch_core_dl "lgsm/functions" "core_dl.sh" "${functionsdir}" "chmodx" "run" "noforcedl" "nohash"
	else
		fn_bootstrap_fetch_file_github "lgsm/functions" "core_dl.sh" "${functionsdir}" "chmodx" "run" "noforcedl" "nohash"
	fi
}

core_messages.sh() {
	functionfile="${FUNCNAME[0]}"
	if [ "$(type fn_fetch_core_dl 2> /dev/null)" ]; then
		fn_fetch_core_dl "lgsm/functions" "core_messages.sh" "${functionsdir}" "chmodx" "run" "noforcedl" "nohash"
	else
		fn_bootstrap_fetch_file_github "lgsm/functions" "core_messages.sh" "${functionsdir}" "chmodx" "run" "noforcedl" "nohash"
	fi
}

core_legacy.sh() {
	functionfile="${FUNCNAME[0]}"
	if [ "$(type fn_fetch_core_dl 2> /dev/null)" ]; then
		fn_fetch_core_dl "lgsm/functions" "core_legacy.sh" "${functionsdir}" "chmodx" "run" "noforcedl" "nohash"
	else
		fn_bootstrap_fetch_file_github "lgsm/functions" "core_legacy.sh" "${functionsdir}" "chmodx" "run" "noforcedl" "nohash"
	fi
}

core_exit.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

core_getopt.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

core_trap.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

core_steamcmd.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

core_github.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Commands

command_backup.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_console.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_debug.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_details.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_sponsor.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_postdetails.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_test_alert.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_monitor.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_start.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_stop.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_validate.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_install.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_install_resources_mta.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_squad_license.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_mods_install.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_mods_update.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_mods_remove.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_fastdl.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_ts3_server_pass.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_restart.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_skeleton.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_wipe.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_send.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Checks

check.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_config.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_deps.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_executable.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_glibc.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_ip.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_last_update.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_logs.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_permissions.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_root.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_status.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_steamcmd.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_system_dir.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_system_requirements.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_tmuxception.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_version.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Compress

compress_unreal2_maps.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

compress_ut99_maps.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Mods

mods_list.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

mods_core.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Dev

command_dev_clear_functions.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_debug.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_detect_deps.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_detect_glibc.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_detect_ldd.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_query_raw.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Fix

fix.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ark.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_av.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_arma3.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_armar.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_bt.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_bo.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_cmw.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_csgo.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_dst.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_hw.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ins.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_kf.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_kf2.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_lo.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_mcb.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_mta.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_nmrih.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_onset.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ro.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_rust.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_rw.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_sfc.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_st.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_steamcmd.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_terraria.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_tf2.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ut3.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_rust.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_samp.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_sdtd.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_sof2.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_squad.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ts3.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ut2k4.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ut.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_unt.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_vh.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_wurm.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_zmr.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Info

info_distro.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

info_game.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

info_messages.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

info_stats.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Alert

alert.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_discord.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_email.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_ifttt.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_mailgun.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_pushbullet.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_pushover.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_gotify.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_telegram.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_rocketchat.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_slack.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}
# Logs

core_logs.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Query

query_gamedig.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Update

command_update_functions.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_update_linuxgsm.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_update.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_check_update.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_ts3.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_minecraft.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_minecraft_bedrock.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_papermc.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_mta.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_factorio.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_jediknight2.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_steamcmd.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_vintagestory.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_ut99.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

fn_update_functions.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

#
## Installer functions
#

fn_autoinstall() {
	autoinstall=1
	command_install.sh
}

install_complete.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_config.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_factorio_save.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_dst_token.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_eula.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_gsquery.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_gslt.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_header.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_logs.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_retry.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_server_dir.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}
install_server_files.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_stats.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_steamcmd.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_ts3.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_ts3db.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_ut2k4.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_dl_ut2k4.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_ut2k4_key.sh() {
	functionfile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Calls code required for legacy servers
core_legacy.sh

# Creates tmp dir if missing
if [ ! -d "${tmpdir}" ]; then
	mkdir -p "${tmpdir}"
fi

# Creates lock dir if missing
if [ ! -d "${lockdir}" ]; then
	mkdir -p "${lockdir}"
fi

# Calls on-screen messages (bootstrap)
core_messages.sh

#Calls file downloader (bootstrap)
core_dl.sh

# Calls the global Ctrl-C trap
core_trap.sh

#!/bin/bash
# LinuxGSM core_modules.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Defines all modules to allow download and execution of modules using fn_fetch_module.
# This module is called first before any other module. Without this file other modules will not load.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

modulesversion="v25.1.6"

# Core

core_dl.sh() {
	modulefile="${FUNCNAME[0]}"
	if [ "$(type fn_fetch_core_dl 2> /dev/null)" ]; then
		fn_fetch_core_dl "lgsm/modules" "core_dl.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nohash"
	else
		fn_bootstrap_fetch_file_github "lgsm/modules" "core_dl.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nohash"
	fi
}

core_messages.sh() {
	modulefile="${FUNCNAME[0]}"
	if [ "$(type fn_fetch_core_dl 2> /dev/null)" ]; then
		fn_fetch_core_dl "lgsm/modules" "core_messages.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nohash"
	else
		fn_bootstrap_fetch_file_github "lgsm/modules" "core_messages.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nohash"
	fi
}

core_legacy.sh() {
	modulefile="${FUNCNAME[0]}"
	if [ "$(type fn_fetch_core_dl 2> /dev/null)" ]; then
		fn_fetch_core_dl "lgsm/modules" "core_legacy.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nohash"
	else
		fn_bootstrap_fetch_file_github "lgsm/modules" "core_legacy.sh" "${modulesdir}" "chmodx" "run" "noforcedl" "nohash"
	fi
}

core_exit.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
	exitcode=$?
	if [ "${exitcode}" -ne 0 ]; then
		echo "fn_fetch_module failed, using fn_bootstrap_fetch_module instead."
		fn_bootstrap_fetch_module
	fi
}

core_getopt.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

core_trap.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

core_steamcmd.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

core_github.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Commands

command_backup.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_console.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_debug.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_details.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_sponsor.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_postdetails.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_test_alert.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_monitor.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_start.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_stop.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_validate.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_install.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_install_resources_mta.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_squad_license.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_mods_install.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_mods_update.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_mods_remove.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_fastdl.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_ts3_server_pass.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_restart.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_skeleton.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_wipe.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_send.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Checks

check.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_config.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_deps.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_executable.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_glibc.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_ip.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_last_update.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_logs.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_permissions.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_root.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_status.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_steamcmd.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_system_dir.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_system_requirements.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_tmuxception.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_version.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Compress

compress_unreal2_maps.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

compress_ut99_maps.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Mods

mods_list.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

mods_core.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Dev

command_dev_clear_modules.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_debug.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_parse_game_details.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_parse_distro_details.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_detect_deps.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_detect_glibc.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_detect_ldd.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_ui.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_dev_query_raw.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Fix

fix.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ark.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_av.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_arma3.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_armar.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_bt.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_bo.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_cmw.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_csgo.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_dst.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_hw.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ins.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_kf.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_kf2.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_mcb.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_mta.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_nmrih.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_onset.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_pvr.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ro.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_rust.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_rw.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_sfc.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_sm.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_st.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_steamcmd.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_terraria.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_tf2.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ut3.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_rust.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_samp.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_sdtd.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_sof2.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_squad.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ts3.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ut2k4.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_ut.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_unt.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_vh.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_wurm.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_xnt.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fix_zmr.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Info

info_distro.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

info_game.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

info_messages.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

info_stats.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Alert

alert.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_discord.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_email.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_ifttt.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_pushbullet.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_pushover.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_gotify.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_telegram.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_rocketchat.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

alert_slack.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}
# Logs

core_logs.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Query

query_gamedig.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

# Update

command_update_modules.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_update_linuxgsm.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_update.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

command_check_update.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_ts3.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_mc.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_mcb.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_pmc.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_mta.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_fctr.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_jk2.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_steamcmd.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_vints.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_ut99.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

update_xnt.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

fn_update_modules.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

#
## Installer modules
#

fn_autoinstall() {
	autoinstall=1
	command_install.sh
}

install_complete.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_config.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_factorio_save.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

check_gamedig.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_dst_token.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_eula.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_gsquery.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_gslt.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_header.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_logs.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_retry.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_server_dir.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}
install_server_files.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_stats.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_steamcmd.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_ts3.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_ts3db.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_ut2k4.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_dl_ut2k4.sh() {
	modulefile="${FUNCNAME[0]}"
	fn_fetch_module
}

install_ut2k4_key.sh() {
	modulefile="${FUNCNAME[0]}"
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

# Creates data dir if missing
if [ ! -d "${datadir}" ]; then
	mkdir -p "${datadir}"
fi

# if $USER id missing set to whoami
if [ -z "${USER}" ]; then
	USER="$(whoami)"
fi

# Calls on-screen messages (bootstrap)
core_messages.sh

#Calls file downloader (bootstrap)
core_dl.sh

# Calls the global Ctrl-C trap
core_trap.sh

#!/bin/bash
# LGSM core_functions.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="060116"

# Description: Defines all functions to allow download and execution of functions using fn_runfunction.
# This function is called first before any other function. Without this file other functions would not load.

#Legacy functions

fn_functions(){
fn_runfunction "${FUNCNAME}"

}

fn_getopt(){
fn_runfunction "${FUNCNAME}"

}


# Core

core_getopt.sh(){
fn_runfunction "${FUNCNAME}"

}

core_messages.sh(){
fn_runfunction "${FUNCNAME}"

}


# Command

command_console.sh(){
fn_runfunction "${FUNCNAME}"

}

command_debug.sh(){
fn_runfunction "${FUNCNAME}"

}

command_details.sh(){
fn_runfunction "${FUNCNAME}"

}

command_email_test.sh(){
fn_runfunction "${FUNCNAME}"

}

command_backup.sh(){
fn_runfunction "${FUNCNAME}"

}

command_monitor.sh(){
fn_runfunction "${FUNCNAME}"

}

command_start.sh(){
fn_runfunction "${FUNCNAME}"

}

command_stop.sh(){
fn_runfunction "${FUNCNAME}"

}

command_validate.sh(){
fn_runfunction "${FUNCNAME}"

}

command_install.sh(){
fn_runfunction "${FUNCNAME}"

}

command_ts3_server_pass.sh(){
fn_runfunction "${FUNCNAME}"

}

fn_restart(){
local modulename="Restarting"
info_config.sh
fn_scriptlog "${servername}"
command_stop.sh
command_start.sh
}


# Checks

check.sh(){
fn_runfunction "${FUNCNAME}"

}

check_config.sh(){
fn_runfunction "${FUNCNAME}"

}

check_ip.sh(){
fn_runfunction "${FUNCNAME}"

}

check_logs.sh(){
fn_runfunction "${FUNCNAME}"

}

check_root.sh(){
fn_runfunction "${FUNCNAME}"

}

check_steamcmd.sh(){
fn_runfunction "${FUNCNAME}"

}

check_steamuser.sh(){
fn_runfunction "${FUNCNAME}"

}

check_systemdir.sh(){
fn_runfunction "${FUNCNAME}"

}

check_tmux.sh(){
fn_runfunction "${FUNCNAME}"

}


# Compress

compress_unreal2_maps.sh(){
fn_runfunction "${FUNCNAME}"

}

compress_ut99_maps.sh(){
fn_runfunction "${FUNCNAME}"

}


# Dev

command_dev_debug.sh(){
fn_runfunction "${FUNCNAME}"

}

command_dev_detect_deps.sh(){
fn_runfunction "${FUNCNAME}"

}


# Fix

fix.sh(){
fn_runfunction "${FUNCNAME}"

}

fix_arma3.sh(){
fn_runfunction "${FUNCNAME}"

}

fix_csgo.sh(){
fn_runfunction "${FUNCNAME}"

}

fix_dst.sh(){
fn_runfunction "${FUNCNAME}"

}

fix_ins.sh(){
fn_runfunction "${FUNCNAME}"

}

fix_steamcmd.sh(){
fn_runfunction "${FUNCNAME}"

}

fix_glibc.sh(){
fn_runfunction "${FUNCNAME}"

}

fix_ro.sh(){
fn_runfunction "${FUNCNAME}"

}

fix_kf.sh(){
fn_runfunction "${FUNCNAME}"

}

fix_ut2k4.sh(){
fn_runfunction "${FUNCNAME}"

}


# Info

info_config.sh(){
fn_runfunction "${FUNCNAME}"

}

info_distro.sh(){
fn_runfunction "${FUNCNAME}"

}

info_glibc.sh(){
fn_runfunction "${FUNCNAME}"

}

info_ts3status.sh(){
fn_runfunction "${FUNCNAME}"

}


# Email

email.sh(){
fn_runfunction "${FUNCNAME}"

}

# Logs

logs.sh(){
fn_runfunction "${FUNCNAME}"

}


# Monitor

monitor_gsquery.sh(){
fn_runfunction "${FUNCNAME}"

}


# Update

update_check.sh(){
fn_runfunction "${FUNCNAME}"

}

update_functions.sh(){
fn_runfunction "${FUNCNAME}"

}

update_dl.sh(){
fn_runfunction "${FUNCNAME}"

}

update_functions.sh(){
fn_runfunction "${FUNCNAME}"

}


#
## Installer functions
#

fn_autoinstall(){
autoinstall=1
command_install.sh
}

install_complete.sh(){
fn_runfunction "${FUNCNAME}"

}

install_config.sh(){
fn_runfunction "${FUNCNAME}"

}

install_gsquery.sh(){
fn_runfunction "${FUNCNAME}"

}

install_gslt.sh(){
fn_runfunction "${FUNCNAME}"

}

install_header.sh(){
fn_runfunction "${FUNCNAME}"

}

install_logs.sh(){
fn_runfunction "${FUNCNAME}"
}

log_dirs.sh(){
fn_runfunction "${FUNCNAME}"
}

install_mod.sh(){
fn_runfunction "${FUNCNAME}"
}

install_retry.sh(){
fn_runfunction "${FUNCNAME}"

}

install_serverdir.sh(){
fn_runfunction "${FUNCNAME}"

}
install_serverfiles.sh(){
fn_runfunction "${FUNCNAME}"
}
install_sourcemod.sh(){
fn_runfunction "${FUNCNAME}"
}

install_steamcmd.sh(){
fn_runfunction "${FUNCNAME}"

}

install_ts3.sh(){
fn_runfunction "${FUNCNAME}"

}

install_ts3db.sh(){
fn_runfunction "${FUNCNAME}"

}

install_ut2k4.sh(){
fn_runfunction "${FUNCNAME}"

}

install_dl_ut2k4.sh(){
fn_runfunction "${FUNCNAME}"

}

install_ut2k4_key.sh(){
fn_runfunction "${FUNCNAME}"

}

install_ut99.sh(){
fn_runfunction "${FUNCNAME}"

}

install_dl_ut99.sh(){
fn_runfunction "${FUNCNAME}"

}

fix_ut99.sh(){
fn_runfunction "${FUNCNAME}"

}

# Calls on-screen messages
core_messages.sh

#!/bin/bash
# LGSM core_functions.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Defines all functions to allow download and execution of functions using fn_fetch_function.
# This function is called first before any other function. Without this file other functions will not load.

# Fixes for legacy code
if [ "${gamename}" == "Teamspeak 3" ]; then
	gamename="TeamSpeak 3"
elif [ "${gamename}" == "Counter Strike: Global Offensive" ]; then
	gamename="Counter-Strike: Global Offensive"
elif [ "${gamename}" == "Counter Strike: Source" ]; then
	gamename="Counter-Strike: Source"
fi

if [ "${emailnotification}" == "on" ]; then
    emailalert="on"
fi

# Code/functions for legacy servers
fn_functions(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fn_getopt(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

# fn_fetch_core_dl also placed here to allow legacy servers to still download core functions
if [ -z "${lgsmdir}" ]||[ -z "${functionsdir}" ]||[ -z "${libdir}" ]; then
	lgsmdir="${rootdir}/lgsm"
	functionsdir="${lgsmdir}/functions"
	libdir="${lgsmdir}/lib"
fi

fn_fetch_core_dl(){
github_file_url_dir="lgsm/functions"
github_file_url_name="${functionfile}"
filedir="${functionsdir}"
filename="${github_file_url_name}"
githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
# If the file is missing, then download
if [ ! -f "${filedir}/${filename}" ]; then
	if [ ! -d "${filedir}" ]; then
		mkdir -p "${filedir}"
	fi
	echo -e "    fetching ${filename}...\c"
	# Check curl exists and use available path
	curlpaths="$(command -v curl 2>/dev/null) $(which curl >/dev/null 2>&1) /usr/bin/curl /bin/curl /usr/sbin/curl /sbin/curl)"
	for curlcmd in ${curlpaths}
	do
		if [ -x "${curlcmd}" ]; then
			break
		fi
	done
	# If curl exists download file
	if [ "$(basename ${curlcmd})" == "curl" ]; then
		curlfetch=$(${curlcmd} -s --fail -o "${filedir}/${filename}" "${githuburl}" 2>&1)
		if [ $? -ne 0 ]; then
			echo -e "${red}FAIL${default}\n"
			echo "${curlfetch}"
			echo -e "${githuburl}\n"
			exit 1
		else
			echo -e "${green}OK${default}"
		fi
	else
		echo -e "${red}FAIL${default}\n"
		echo "Curl is not installed!"
		echo -e ""
		exit 1
	fi
	chmod +x "${filedir}/${filename}"
fi
source "${filedir}/${filename}"
}


# Core

core_dl.sh(){
# Functions are defined in core_functions.sh.
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_exit.sh(){
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_getopt.sh(){
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_trap.sh(){
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_messages.sh(){
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}


# Command

command_console.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_debug.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_postdetails.sh(){
functionfile="${FUNCNAME}"
tempffname=$functionfile
fn_fetch_function
functionfile="command_details.sh"
fn_fetch_function
functionfile=$tempffname
}

command_details.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_test_alert.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_backup.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_monitor.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_start.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_stop.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_validate.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_install.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_fastdl.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_ts3_server_pass.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_restart.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}


# Checks

check.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

check_config.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

check_deps.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

check_glibc.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

check_ip.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

check_logs.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

check_permissions.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

check_root.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

check_status.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

check_steamcmd.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

check_system_dir.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

check_system_requirements.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

check_tmux.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}


# Compress

compress_unreal2_maps.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

compress_ut99_maps.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}


# Dev

command_dev_debug.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_dev_detect_deps.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_dev_detect_glibc.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_dev_detect_ldd.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

# Fix

fix.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fix_arma3.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fix_csgo.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fix_dst.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fix_ges.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fix_ins.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fix_steamcmd.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fix_glibc.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fix_ro.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fix_kf.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fix_ut2k4.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fix_ut.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

# Info

info_config.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

info_distro.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

info_glibc.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

info_parms.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}


# Alert

alert.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

alert_email.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

alert_pushbullet.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

# Logs

logs.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}


# Monitor

monitor_gsquery.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}


# Update

command_update_functions.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

command_update.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

update_ts3.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

update_minecraft.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

update_mumble.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

update_steamcmd.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fn_update_functions.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}


#
## Installer functions
#

fn_autoinstall(){
autoinstall=1
command_install.sh
}

install_complete.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_config.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_gsquery.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_gslt.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_header.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_logs.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_minecraft_eula.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_retry.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_server_dir.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}
install_server_files.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_steamcmd.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_ts3.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_ts3db.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_ut2k4.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_dl_ut2k4.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

install_ut2k4_key.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

fix_ut99.sh(){
functionfile="${FUNCNAME}"
fn_fetch_function
}

# Calls the global Ctrl-C trap
core_trap.sh

# Calls on-screen messages
core_messages.sh

#Calls file downloader
core_dl.sh

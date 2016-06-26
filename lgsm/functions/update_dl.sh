#!/bin/bash
# LGSM update_dl.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Runs a server update.

modulename="Update"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_steamcmd_dl(){
	cd "${rootdir}"
	cd "steamcmd"

	# Detects if unbuffer command is available.
	if [ $(command -v unbuffer) ]; then
		unbuffer=unbuffer
        elif  [ $(command -v stdbuf) ]; then
		unbuffer="stdbuf -i0 -o0 -e0"
	fi

	if [ "${engine}" == "goldsource" ]; then
		${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod ${appidmod} +app_update "${appid}" +quit | tee -a "${scriptlog}"
	else
		${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_update "${appid}" +quit | tee -a "${scriptlog}"
	fi

	fix.sh
}

fn_teamspeak3_dl(){
	cd "${rootdir}"
	echo -e "downloading teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2...\c"
	fn_script_log "Downloading teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2"
	wget -N /dev/null http://dl.4players.de/ts/releases/${ts3_version_number}/teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2 2>&1 | grep -F HTTP | cut -c45-| uniq
	sleep 1
	echo -e "extracting teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2...\c"
	fn_script_log "Extracting teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2"
	tar -xf "teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2" 2> "${scriptlogdir}/.${servicename}-tar-error.tmp"
	local status=$?
	if [ ${status} -eq 0 ]; then
		echo "OK"
	else
		echo "FAIL - Exit status ${status}"
		fn_script_log "Failed to extract - Exit status ${status}"
		sleep 1
		cat "${scriptlogdir}/.${servicename}-tar-error.tmp"
		cat "${scriptlogdir}/.${servicename}-tar-error.tmp" >> "${scriptlog}"
		rm "${scriptlogdir}/.${servicename}-tar-error.tmp"
		fn_script_log "Failure! Unable to update"
		exit ${status}
	fi
	echo -e "copying to ${filesdir}...\c"
	fn_script_log "Copying to ${filesdir}"
	cp -R "${rootdir}/teamspeak3-server_linux_${ts3arch}/"* "${filesdir}" 2> "${scriptlogdir}/.${servicename}-cp-error.tmp"
	local status=$?
	if [ ${status} -eq 0 ]; then
		echo "OK"
	else
		echo "FAIL - Exit status ${status}"
		fn_script_log "Failed to copy - Exit status ${status}"
		sleep 1
		cat "${scriptlogdir}/.${servicename}-cp-error.tmp"
		cat "${scriptlogdir}/.${servicename}-cp-error.tmp" >> "${scriptlog}"
		rm "${scriptlogdir}/.${servicename}-cp-error.tmp"
		fn_script_log "Failure! Unable to update"
		exit ${status}
	fi
	rm -f teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2
	rm -rf "${rootdir}/teamspeak3-server_linux_${ts3arch}"
}

check.sh
info_config.sh
fn_print_dots "Updating ${servername}"
sleep 1
fn_print_ok_nl "Updating ${servername}"
fn_script_log "Updating ${servername}"
sleep 1
if [ "${gamename}" == "Teamspeak 3" ]; then
	fn_teamspeak3_dl
else
	fn_steamcmd_dl
fi

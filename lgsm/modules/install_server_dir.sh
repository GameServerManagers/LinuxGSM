#!/bin/bash
# LinuxGSM install_server_dir.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Creates the server directory.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${lightyellow}Server Directory${default}"
echo -e "${bold}=================================${default}"
fn_sleep_time
echo -en "creating ( ${serverfiles} )"

if [ -d "${serverfiles}" ]; then
	fn_print_skip_eol_nl
	echo -e "${italic}A game server is already exists at this location.${default}"
else
	fn_print_ok_eol_nl
fi

if [ -z "${autoinstall}" ]; then
	if ! fn_prompt_yn "Continue?" Y; then
		exitcode=0
		core_exit.sh
	fi
fi
if [ ! -d "${serverfiles}" ]; then
	mkdir -v "${serverfiles}"
fi

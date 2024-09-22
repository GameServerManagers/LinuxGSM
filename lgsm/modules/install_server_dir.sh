#!/bin/bash
# LinuxGSM install_server_dir.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Creates the server directory.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${bold}${lightyellow}Server Directory${default}"
fn_messages_separator
if [ -d "${serverfiles}" ]; then
	fn_print_warning_nl "A server is already installed here."
fi
pwd
if [ -z "${autoinstall}" ]; then
	if ! fn_prompt_yn "Continue?" Y; then
		exitcode=0
		core_exit.sh
	fi
fi
if [ ! -d "${serverfiles}" ]; then
	mkdir -v "${serverfiles}"
fi

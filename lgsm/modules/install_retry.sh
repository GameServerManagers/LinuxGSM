#!/bin/bash
# LinuxGSM install_retry.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Asks for installation retry after failure.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if fn_prompt_yn "Retry install?" Y; then
	command_install.sh
	core_exit.sh
else
	exitcode=0
	core_exit.sh
fi

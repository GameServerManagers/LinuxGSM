#!/bin/bash
# LinuxGSM install_retry.sh module
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Contributors: http://linuxgsm.com/contrib
# Description: Asks for installation retry after failure.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if fn_prompt_yn "Retry install?" Y; then
	command_install.sh; core_exit.sh
else
	exitcode=0
	core_exit.sh
fi

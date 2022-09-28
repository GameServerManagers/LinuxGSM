#!/bin/bash
# LinuxGSM fix_av.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Avorion

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"


if [ "${postinstall}" == "1" ]; then

	fn_print_information "starting ${gamename} server to generate configs."
	command_start.sh
	sleep 30
	command_stop.sh

fi



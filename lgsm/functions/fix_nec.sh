#!/bin/bash
# LinuxGSM fix_nec.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Starts a server to autogenerate configs after installation

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"


if [ "${postinstall}" == "1" ]; then
	fn_print_information "starting ${gamename} server to generate configs."
	exitbypass=1
	command_start.sh
	fn_firstcommand_reset
	sleep 10
	exibypass=1
	command_stop.sh
	fn_firstcommand_reset
fi

fn_default_config_local
fn_set_config_vars
fn_list_config_locations



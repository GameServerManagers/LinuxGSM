#!/bin/bash
# LinuxGSM check_executable.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if server executable exists.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# #4241 temporary fix for Satisfactory for upgrade betweern Update 7 & Update 8 - remove this once update 8 is released
if [ "${shortname}" == "sf" ]; then
	if [ ! -f "${serverfiles}/Engine/Binaries/Linux/UE4Server-Linux-Shipping" ]; then
		ln -s "${serverfiles}/Engine/Binaries/Linux/UnrealServer-Linux-Shipping" "${serverfiles}/Engine/Binaries/Linux/UE4Server-Linux-Shipping"
	fi
fi

# Check if executable exists
execname=$(basename "${executable}")
if [ ! -f "${executabledir}/${execname}" ]; then
	fn_print_fail_nl "executable was not found"
	echo -e "* ${executabledir}/${execname}"
	if [ -d "${lgsmlogdir}" ]; then
		fn_script_log_fail "Executable was not found: ${executabledir}/${execname}"
	fi
	unset exitbypass
	core_exit.sh
fi

#!/bin/bash
# LinuxGSM fix_ns2.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Natural Selection 2.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${httpip}" == "0.0.0.0" ]; then
	routeip="$(${ipcommand:-ip} -o -4 route get 1.1.1.1 2> /dev/null | grep -oP 'src \K[0-9.]+')"
	if [ -n "${routeip}" ]; then
		fixname="web admin and mod server address ${routeip}"
		fn_fix_msg_start
		httpip="${routeip}"
		fn_fix_msg_end
	fi
fi

#!/bin/bash
# LinuxGSM fix_ts3.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves various issues with Teamspeak 3.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: makes libmariadb2 available #1924.
if [ ! -f "${serverfiles}/libmariadb.so.2" ]; then
	fixname="libmariadb.so.2"
	fn_fix_msg_start
	cp "${serverfiles}/redist/libmariadb.so.2" "${serverfiles}/libmariadb.so.2"
	fn_fix_msg_end
fi

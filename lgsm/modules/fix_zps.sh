#!/bin/bash
# LinuxGSM fix_zps.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Zombie Panic! Source.

# shellcheck disable=SC2034 # Used by the module loader.
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

for libcurl in /usr/lib/i386-linux-gnu/libcurl.so.4 /usr/lib32/libcurl.so.4 /usr/lib/libcurl.so.4; do
	if [ -f "${libcurl}" ]; then
		if [ "$(readlink "${serverfiles}/bin/libcurl.so")" != "${libcurl}" ]; then
			# shellcheck disable=SC2034 # Used by fn_fix_msg_start_nl and fn_fix_msg_end.
			fixname="libcurl.so x86"
			fn_fix_msg_start_nl
			ln -sf "${libcurl}" "${serverfiles}/bin/libcurl.so"
			fn_fix_msg_end
		fi
		break
	fi
done

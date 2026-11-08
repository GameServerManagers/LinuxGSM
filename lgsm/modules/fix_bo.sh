#!/bin/bash
# LinuxGSM fix_hw.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Ballistic Overkill.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/BODS_Data/Plugins/x86_64"

if [ -f "${servercfgfullpath}" ] && ! cmp -s "${servercfgfullpath}" "${serverfiles}/config.txt"; then
	fixname="copy ${servercfg} to config.txt"
	fn_fix_msg_start
	cp -f "${servercfgfullpath}" "${serverfiles}/config.txt"
	exitcode=$?
	fn_fix_msg_end
fi

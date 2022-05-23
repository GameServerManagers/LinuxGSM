#!/bin/bash
# LinuxGSM fix_armar.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves an issue with Arma Reforger.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: Profile directory doesn't exist.
# Issue Link: https://feedback.bistudio.com/T164845
if [ ! -d "${serverprofilefullpath}" ]; then
	fixname="Profile directory doesn't exist"
	fn_fix_msg_start
	mkdir -p "${serverprofilefullpath}"
	fn_fix_msg_end
fi

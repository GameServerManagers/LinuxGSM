#!/bin/bash
# LinuxGSM fix_armar.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Arma Reforger.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: Profile directory doesn't exist.
# Issue Link: https://feedback.bistudio.com/T164845
if [ ! -d "${serverprofilefullpath}" ]; then
	fixname="Profile directory doesn't exist"
	fn_fix_msg_start
	mkdir -p "${serverprofilefullpath}"
	fn_fix_msg_end
fi

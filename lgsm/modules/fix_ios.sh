#!/bin/bash
# LinuxGSM fix_ios.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with IOSoccer.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: IOSoccer 64-bit server stuck reloading the map #5023.
if [ -f "${servercfgfullpath}" ] && grep -qE '^\s*map\s' "${servercfgfullpath}"; then
	fixname="remove map from ${servercfg}"
	fn_fix_msg_start
	sed -i -E 's|^(\s*map\s.*)$|// \1|' "${servercfgfullpath}"
	fn_fix_msg_end
fi

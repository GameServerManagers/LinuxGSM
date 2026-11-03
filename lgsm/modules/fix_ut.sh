#!/bin/bash
# LinuxGSM fix_ut.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Unreal Tournament.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export GLIBC_TUNABLES="${GLIBC_TUNABLES:+${GLIBC_TUNABLES}:}glibc.rtld.execstack=2"

if [ ! -x "${executabledir}/${executable}" ]; then
	echo -e "chmod +x ${executabledir}/${executable}"
	chmod +x "${executabledir}/${executable}"
	fn_sleep_time
fi

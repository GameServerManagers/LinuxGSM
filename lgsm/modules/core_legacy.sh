#!/bin/bash
# LinuxGSM core_legacy.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Code for backwards compatability with older versions of LinuxGSM.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -z "${socketname}" ]; then
	socketname="${sessionname}"
fi

if [ -n "${webadminuser}" ]; then
	httpuser="${webadminuser}"
fi

if [ -n "${webadminpass}" ]; then
	httppassword="${webadminpass}"
fi

if [ -n "${webadminport}" ]; then
	httpport="${webadminport}"
fi

if [ -n "${webadminip}" ]; then
	httpip="${webadminip}"
fi

if [ -n "${gameworld}" ]; then
	worldname="${gameworld}"
fi

if [ -n "${autosaveinterval}" ]; then
	saveinterval="${autosaveinterval}"
fi

# Added as part of migrating functions dir to modules dir.
# Will remove functions dir if files in modules dir older than 14 days
functionsdir="${lgsmdir}/modules"
if [ -d "${lgsmdir}/functions" ]; then
	if [ "$(find "${lgsmdir}/modules"/ -type f -mtime +"14" | wc -l)" -ne "0" ]; then
		rm -rf "${lgsmdir:?}/functions"
	fi
fi

fn_parms() {
	fn_reload_startparameters
	parms="${startparameters}"
}

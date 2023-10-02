#!/bin/bash
# LinuxGSM fix_lo.sh module
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Last Oasis.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

appidfile=${executabledir}/steam_appid.txt
if [ ! -f "${appidfile}" ]; then
	fn_print_information "adding ${appidfile} to ${gamename} server."
	echo "903950" > "${appidfile}"
else
	fn_print_information "${appidfile} already exists. No action to be taken."
fi

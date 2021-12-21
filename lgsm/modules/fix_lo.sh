#!/bin/bash
# LinuxGSM fix_lo.sh module
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves installation issue with Last Oasis

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

local APPID_FILE=${executabledir}/steam_appid.txt
if [ ! -f "${APPID_FILE}" ]; then
    fn_print_information "adding ${APPID_FILE} to ${gamename} server."
    fn_sleep_time
    echo "903950" > "${APPID_FILE}"
else
    fn_print_information "${APPID_FILE} already exists. No action to be taken."
    fn_sleep_time
fi

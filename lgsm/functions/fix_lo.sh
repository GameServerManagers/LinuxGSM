#!/bin/bash
# LinuxGSM fix_lo.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves installation issue with Last Oasis

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

local APPID_FILE=${executabledir}/steam_appid.txt
if [ ! -f "${APPID_FILE}" ]; then
    fn_print_information "add ${APPID_FILE} to ${gamename} server."
    echo "903950" > ${APPID_FILE}
else
    fn_print_information "${APPID_FILE} already exists. No action to be taken."
fi
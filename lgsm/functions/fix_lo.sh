#!/bin/bash
# LinuxGSM fix_lo.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Last Oasis

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

local APPID_FILE = ${executabledir}/steam_appid.txt
if [! -f "${APPID_FILE}" ]; then
    echo "903950" > ${APPID_FILE}
fi
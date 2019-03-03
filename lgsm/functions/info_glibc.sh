#!/bin/bash
# LinuxGSM info_glibc.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Stores details on servers Glibc requirements.

local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
echo "${serverlist}"
echo "${shortname}"
glibcrequired=$(awk -F "," '{ print $1","$5 }' "${serverlist}" | grep -w "${shortname}" | awk -F "," '{ print $2 }')

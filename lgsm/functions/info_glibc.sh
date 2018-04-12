#!/bin/bash
# LinuxGSM info_glibc.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Stores details on servers Glibc requirements.

local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

glibcrequired=$(grep "${shortname}" "${serverlist}" | awk -F "," '{ print $5 }')
glibcfix=$(grep "${shortname}" "${serverlist}" | awk -F "," '{ print $6 }')
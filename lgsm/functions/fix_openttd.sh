#!/bin/bash
# LinuxGSM fix_ottd.sh function
# Author: ttocszed00
# Website: https://linuxgsm.com
# Description: Compiles Open Transport Tycoon Delux server after downloading source files.
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

local modulename="FIX"
local commandaction="Fix"

mkdir "${rootdir}/.openttd/baseset"
fn_print_information_nl "Downloading graphics pack"
fn_fetch_file "https://cdn.openttd.org/opengfx-releases/0.6.0/opengfx-0.6.0-all.zip" "" "" "" "${tmpdir}" "opengfx-0.6.0-all.zip" "nochmodx" "norun" "noforce" "994d8ce816542b74130964971736d4d6"
fn_dl_extract "${tmpdir}" "opengfx-0.6.0-all.zip" "${rootdir}/.openttd/baseset"
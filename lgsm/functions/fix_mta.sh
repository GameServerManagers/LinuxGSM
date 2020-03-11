#!/bin/bash
# LinuxGSM fix_mta.sh function
# Author: Daniel Gibbs
# Contributor: ChaosMTA
# Website: https://linuxgsm.com
# Description: Installs the libmysqlclient for database functions on the server
local commandname="FIX"
local commandaction="Fix"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

if [ ! -f "${lgsmdir}/lib/libmysqlclient.so.16" ]; then
	fixname="libmysqlclient16"
	fn_fix_msg_start_nl
	fn_sleep_time
	fn_fetch_file "https://nightly.mtasa.com/files/modules/64/libmysqlclient.so.16" "${lgsmdir}/lib" "libmysqlclient.so.16" "chmodx" "norun" "noforce" "6c188e0f8fb5d7a29f4bc413b9fed6c2"
	fn_fix_msg_end
fi

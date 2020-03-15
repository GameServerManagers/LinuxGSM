#!/bin/bash
# LinuxGSM fix_dst.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Don't Starve Together.

local modulename="FIX"
local commandaction="Fix"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

# Fixes: ./dontstarve_dedicated_server_nullrenderer: ./lib32/libcurl-gnutls.so.4: no version information available (required by ./dontstarve_dedicated_server_nullrenderer).
# Issue only occures on CentOS as libcurl-gnutls.so.4 is called libcurl.so.4 on CentOS.
if [ -f "/etc/redhat-release" ]&&[ ! -f "${serverfiles}/bin/lib32/libcurl-gnutls.so.4" ]; then
	fixname="libcurl-gnutls.so.4"
	fn_fix_msg_start
	ln -s "/usr/lib/libcurl.so.4" "${serverfiles}/bin/lib32/libcurl-gnutls.so.4"
	fn_fix_msg_end
fi

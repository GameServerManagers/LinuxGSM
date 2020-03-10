#!/bin/bash
# LinuxGSM fix_tf2.sh function
# Author: Vector Sigma
# Website: https://github.com/vectorsigma
# Description: Resolves various issues with Team Fortress 2.

local modulename="FIX"
local commandaction="Fix"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

# Fixes: Team Fortress 2 Segmentation fault for Red-Hat Distros #2062.
if [ -f "/etc/redhat-release" ]&&[ ! -f "${serverfiles}/bin/libcurl-gnutls.so.4" ]; then
	fixname="libcurl-gnutls.so.4"
	fn_fix_msg_start
	ln -s "/usr/lib/libcurl.so.4" "${serverfiles}/bin/libcurl-gnutls.so.4"
	fn_fix_msg_end
fi

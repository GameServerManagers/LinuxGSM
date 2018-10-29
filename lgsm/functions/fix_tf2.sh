#!/bin/bash
# LinuxGSM fix_tf2.sh function
# Author: Vector Sigma
# Website: https://github.com/vectorsigma
# Description: Resolves various issues with Team Fortress 2.

local commandname="FIX"
local commandaction="Fix"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [[ -f /etc/redhat-release ]]; then
	echo "Applying missing libcurl-gnutls.so.4 fix for Redhat-based systems."
	cd ${serverfiles}/bin || exit
	if [[ -L libcurl-gnutls.so.4 ]]; then
		echo "Fix already applied."
	else
		curl_lib="/usr/lib/libcurl.so.4"
		if [[ -L $curl_lib ]]; then
			ln -nfs $curl_lib libcurl-gnutls.so.4
			if [[ "$?" != "0" ]]; then
				echo "Fix failed, ln exitied non-zero."
			else
				echo "Fix applied successfully."
			fi
		else
			echo "Missing library: $curl_lib, dnf -y install libcurl.i686"
		fi
	 fi
fi

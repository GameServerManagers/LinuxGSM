#!/bin/bash
# LinuxGSM fix_pvr.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves various issues with Pavlov VR.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/linux64"

if ldd "${executabledir}/PavlovServer-Linux-Shipping" 2>&1 | grep -qE "libc\+\+(abi)?\.so\.1 => not found"; then
	# shellcheck disable=SC2034 # Used by fn_fix_msg_start_nl and fn_fix_msg_end.
	fixname="libc++ amd64"
	fn_fix_msg_start_nl
	fn_fetch_file "https://linuxgsm.download/libraries/libcxx-amd64-11.0.1-2.tar.xz" "" "" "" "${tmpdir}" "libcxx-amd64-11.0.1-2.tar.xz" "nochmodx" "norun" "noforce" "2a75a54c6637d217e3821220b0d5571f"
	fn_dl_extract "${tmpdir}" "libcxx-amd64-11.0.1-2.tar.xz" "${serverfiles}/linux64"
	fn_clear_tmp
	fn_fix_msg_end
fi

if [ ! -f "${serverfiles}/linux64/libc++.so" ]; then
	if [ -f "/usr/lib/x86_64-linux-gnu/libc++.so.1" ]; then
		cp "/usr/lib/x86_64-linux-gnu/libc++.so.1" "${serverfiles}/linux64/libc++.so"
	elif [ -f "${serverfiles}/linux64/libc++.so.1" ]; then
		cp -L "${serverfiles}/linux64/libc++.so.1" "${serverfiles}/linux64/libc++.so"
	fi
fi

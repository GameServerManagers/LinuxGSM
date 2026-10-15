#!/bin/bash
# LinuxGSM fix_bfv.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Battlefield: Vietnam.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}"

if ldd "${executabledir}/bfv_linded.static" 2>&1 | grep -qE "lib(ncurses|tinfo)\.so\.5 => not found"; then
	fixname="libncurses5 i386"
	fn_fix_msg_start_nl
	fn_fetch_file "http://linuxgsm.download/libraries/libncurses5-i386-6.3-2ubuntu0.3.tar.xz" "" "" "" "${tmpdir}" "libncurses5-i386-6.3-2ubuntu0.3.tar.xz" "nochmodx" "norun" "noforce" "ee141cb3a843e4201786b6f188347666"
	fn_dl_extract "${tmpdir}" "libncurses5-i386-6.3-2ubuntu0.3.tar.xz" "${serverfiles}"
	fn_clear_tmp
	fn_fix_msg_end
fi

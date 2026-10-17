#!/bin/bash
# LinuxGSM fix_cod2.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Call of Duty 2.

# shellcheck disable=SC2034 # Used by the module loader.
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}"

if ldd "${executabledir}/cod2_lnxded" 2>&1 | grep -q "libstdc++\.so\.5 => not found"; then
	# shellcheck disable=SC2034 # Used by fn_fix_msg_start_nl and fn_fix_msg_end.
	fixname="libstdc++5 i386"
	fn_fix_msg_start_nl
	fn_fetch_file "https://linuxgsm.download/libraries/libstdc++5-i386-3.3.6-34.tar.xz" "" "" "" "${tmpdir}" "libstdc++5-i386-3.3.6-34.tar.xz" "nochmodx" "norun" "noforce" "288a4cc9d6b7647f28c702028437e0f3"
	fn_dl_extract "${tmpdir}" "libstdc++5-i386-3.3.6-34.tar.xz" "${serverfiles}"
	fn_clear_tmp
	fn_fix_msg_end
fi

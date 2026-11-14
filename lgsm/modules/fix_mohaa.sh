#!/bin/bash
# LinuxGSM fix_mohaa.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Medal of Honor: Allied Assault and its expansions.

# shellcheck disable=SC2034 # Used by the module loader.
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}"

if ldd "${executabledir}/${executable#./}" 2>&1 | grep -q "libstdc++\.so\.5 => not found"; then
	# shellcheck disable=SC2034 # Used by fn_fix_msg_start_nl and fn_fix_msg_end.
	fixname="libstdc++5 i386"
	fn_fix_msg_start_nl
	fn_fetch_file "https://linuxgsm.download/libraries/libstdc++5-i386-3.3.6-34.tar.xz" "" "" "" "${tmpdir}" "libstdc++5-i386-3.3.6-34.tar.xz" "nochmodx" "norun" "noforce" "288a4cc9d6b7647f28c702028437e0f3"
	fn_dl_extract "${tmpdir}" "libstdc++5-i386-3.3.6-34.tar.xz" "${serverfiles}"
	fn_clear_tmp
	fn_fix_msg_end
fi

if [ -f "${executabledir}/${executable#./}" ]; then
	executablemd5="$(md5sum "${executabledir}/${executable#./}" | awk '{print $1}')"
	if [ "${executablemd5}" == "6d8c51fa1a3a7b3d392348dd6cb2e4c5" ] || [ "${executablemd5}" == "b1e012bc32ea60d93b99dea8e8a33b86" ] || [ "${executablemd5}" == "32ec01ef4e9986cf4a0de27b3157cabf" ]; then
		# shellcheck disable=SC2034 # Used by fn_fix_msg_start and fn_fix_msg_end.
		fixname="master server"
		fn_fix_msg_start
		LC_ALL=C sed -i -e 's/master\.gamespy\.com/master.gametir.com/g' -e 's/master\.x-null\.net\x00/master.gametir.com/g' "${executabledir}/${executable#./}"
		fn_fix_msg_end
	fi
fi

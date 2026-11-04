#!/bin/bash
# LinuxGSM fix_ahl.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Action Half-Life.

# shellcheck disable=SC2034 # Used by the module loader.
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export GLIBC_TUNABLES="${GLIBC_TUNABLES:+${GLIBC_TUNABLES}:}glibc.rtld.execstack=2"

rehldsversion="3.15.0.896"
rehldsfile="rehlds-bin-${rehldsversion}.zip"

if ! grep -qs '"BetaKey"[[:space:]]*"steam_legacy"' "${serverfiles}/steamapps/appmanifest_90.acf"; then
	fn_print_warn_nl "ReHLDS requires the steam_legacy branch: run ./${selfname} force-update"
	fn_script_log_warn "ReHLDS requires the steam_legacy branch: run ./${selfname} force-update"
elif [ "$(md5sum "${serverfiles}/engine_i486.so" 2> /dev/null | awk '{print $1}')" != "a3aa351c97922f17b8290dce3f5b9bf0" ]; then
	# shellcheck disable=SC2034 # Used by fn_fix_msg_start_nl and fn_fix_msg_end.
	fixname="ReHLDS ${rehldsversion}"
	fn_fix_msg_start_nl
	fn_fetch_file "https://github.com/rehlds/ReHLDS/releases/download/${rehldsversion}/${rehldsfile}" "" "" "" "${tmpdir}" "${rehldsfile}" "nochmodx" "norun" "noforce" "87b8dd8bce18ccc2295069f7382bb4d3"
	fn_dl_extract "${tmpdir}" "${rehldsfile}" "${serverfiles}" "bin/linux32"
	chmod +x "${serverfiles}/hlds_linux" "${serverfiles}/hltv"
	fn_clear_tmp
	fn_fix_msg_end
fi

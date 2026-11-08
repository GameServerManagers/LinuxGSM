#!/bin/bash
# LinuxGSM fix_ut99.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Unreal Tournament 99.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [[ "${startparameters}" == *"-nohomedir"* ]] && [ -d "${HOME}/.utpg/System" ]; then
	while IFS= read -r -d '' homeini; do
		fixname="move $(basename "${homeini}") from ${HOME}/.utpg/System to ${systemdir}"
		fn_fix_msg_start
		mv --backup=numbered "${homeini}" "${systemdir}/"
		exitcode=$?
		fn_fix_msg_end
	done < <(find "${HOME}/.utpg/System" -maxdepth 1 -type f -name "*.ini" -print0)
fi

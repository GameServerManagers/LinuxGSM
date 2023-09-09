#!/bin/bash
# LinuxGSM fix_rust.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Rust.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: [Raknet] Server Shutting Down (Shutting Down).
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/RustDedicated_Data/Plugins/x86_64"

# Part of random seed feature.
# If seed is not defined by user generate a seed file.
if [ -z "${seed}" ] || [ "${seed}" == "0" ]; then
	if [ ! -f "${datadir}/${selfname}-seed.txt" ]; then
		shuf -i 1-2147483647 -n 1 > "${datadir}/${selfname}-seed.txt"
		seed="$(cat "${datadir}/${selfname}-seed.txt")"
		fn_print_info_nl "Generating new random seed (${cyan}${seed}${default})"
		fn_script_log_pass "Generating new random seed (${cyan}${seed}${default})"
	fi
	seed="$(cat "${datadir}/${selfname}-seed.txt")"
	randomseed=1
fi

# If Carbon mod is installed, run enviroment.sh
if [ -f "${serverfiles}/carbon/tools/environment.sh" ]; then
	fn_print_info_nl "Running Carbon environment.sh"
	fn_script_log_info "Running Carbon environment.sh"
	# shellcheck source=/dev/null
	source "${serverfiles}/carbon/tools/environment.sh"
fi

#!/bin/bash
# LinuxGSM fix_rust.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Rust.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: [Raknet] Server Shutting Down (Shutting Down).
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/RustDedicated_Data/Plugins/x86_64"

# Part of random seed feature.
# If the seed is not defined by the user, generate a seed file.
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

# fix for #4268
# insert set -g default-terminal "screen-256color" into ~/.tmux.conf
if [ -f "${serverfiles}/RustDedicated_Data/Managed/Oxide.Rust.dll" ]; then
	# tmux version is 3.3 or higher
	tmuxvdigit="$(tmux -V | sed "s/tmux //" | sed -n '1 p' | tr -cd '[:digit:]')"
	if [ "${tmuxvdigit}" -ge "33" ]; then
		if [ ! -f "${HOME}/.tmux.conf" ]; then
			touch "${HOME}/.tmux.conf"
		fi
		if ! grep -q "set -g default-terminal \"screen-256color\"" "${HOME}/.tmux.conf"; then
			fixname="tmux screen-256color"
			fn_fix_msg_start
			echo "set -g default-terminal \"screen-256color\"" >> "${HOME}/.tmux.conf"
			fn_fix_msg_end
		fi
	fi
fi

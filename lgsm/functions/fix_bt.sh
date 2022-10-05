#!/bin/bash
# LinuxGSM fix_bt.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves an issue with Barotrauma.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: Missing user data directory error.
if [ ! -d "${XDG_DATA_HOME:="${HOME}/.local/share"}/Daedalic Entertainment GmbH/Barotrauma" ]; then
	fixname="Missing user data directory error."
	fn_fix_msg_start
	mkdir -p "${XDG_DATA_HOME:="${HOME}/.local/share"}/Daedalic Entertainment GmbH/Barotrauma"
	fn_fix_msg_end
fi

#!/bin/bash
# LinuxGSM fix_bt.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Barotrauma.

module_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: Missing user data directory error.
if [ ! -d "${XDG_DATA_HOME:="${HOME}/.local/share"}/Daedalic Entertainment GmbH/Barotrauma" ]; then
	fixname="Missing user data directory error."
	fn_fix_msg_start
	mkdir -p "${XDG_DATA_HOME:="${HOME}/.local/share"}/Daedalic Entertainment GmbH/Barotrauma"
	fn_fix_msg_end
fi

# check if startscript is with windows line endings and reformat it
if file -b "${serverfiles}${executable:1}" | grep -q CRLF; then
	fixname="Convert ${executable:2} to unix file format"
	fn_fix_msg_start
	dos2unix -q "${serverfiles}${executable:1}"
	fn_fix_msg_end
fi

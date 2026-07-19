#!/bin/bash
# LinuxGSM fix_sfc.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issue that the default rcon password is not changed.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -f "${servercfgfullpath}" ]; then
	# check if default password is set "changeme"
	currentpass=$(grep -E "^rcon_password" "${servercfgfullpath}" | sed 's/^rcon_password //')
	defaultpass="changeme"
	# check if default password is set
	if [ "${currentpass}" == "${defaultpass}" ]; then
		fixname="change default rcon password"
		fn_fix_msg_start
		fn_script_log_info "Changing rcon/admin password."
		randomstring=$(tr -dc 'A-Za-z0-9_' < /dev/urandom 2> /dev/null | head -c 8 | xargs)
		rconpass="admin${randomstring}"
		sed -i "s/rcon_password changeme/rcon_password ${rconpass}/g" "${servercfgfullpath}"
		fn_fix_msg_end
	fi
	# check if the hostname is the default name
	currenthostname=$(grep -E "^hostname" "${servercfgfullpath}" | sed 's/^hostname //')
	defaulthostname="SA-MP 0.3 Server"
	if [ "${currenthostname}" == "${defaulthostname}" ]; then
		fixname="change default hostname"
		fn_fix_msg_start
		fn_script_log_info "Changing default hostname to LinuxGSM"
		sed -i "s/hostname ${defaulthostname}/hostname LinuxGSM/g" "${servercfgfullpath}"
		fn_fix_msg_end
	fi
fi

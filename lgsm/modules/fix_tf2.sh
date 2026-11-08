#!/bin/bash
# LinuxGSM fix_tf2.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Team Fortress 2.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: Team Fortress 2 Segmentation fault for Red-Hat Distros #2062.
if [ -f "/etc/redhat-release" ] && [ ! -f "${serverfiles}/bin/libcurl-gnutls.so.4" ]; then
	fixname="libcurl-gnutls.so.4"
	fn_fix_msg_start
	ln -s "/usr/lib/libcurl.so.4" "${serverfiles}/bin/libcurl-gnutls.so.4"
	fn_fix_msg_end
fi

# Fixes: SourceMod extensions without 64-bit builds failing to load #4841.
if [ "${executable}" == "./srcds_run_64" ] && [ -d "${systemdir}/addons/sourcemod" ] && ! grep -qsE "^[[:blank:]]*executable=" "${configdirserver}/common.cfg" "${configdirserver}/secrets-common.cfg" "${configdirserver}/${selfname}.cfg" "${configdirserver}/secrets-${selfname}.cfg"; then
	fn_print_info_nl "SourceMod detected, starting 32-bit server. Set executable=\"./srcds_run_64\" in ${selfname}.cfg to use 64-bit"
	fn_script_log_info "SourceMod detected, starting 32-bit server. Set executable=\"./srcds_run_64\" in ${selfname}.cfg to use 64-bit"
	executable="./srcds_run"
fi

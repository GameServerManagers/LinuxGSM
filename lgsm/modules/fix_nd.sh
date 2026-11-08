#!/bin/bash
# LinuxGSM fix_nd.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Nuclear Dawn.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ ! -f "${serverfiles}/nucleardawn/gameinfo.txt" ]; then
	fixname="game content"
	fn_fix_msg_start_nl
	steamcmdlog="${lgsmlogdir}/${selfname}-steamcmd.log"
	rm -f "${steamcmdlog:?}"
	if [ -d "${steamcmddir}" ]; then
		cd "${steamcmddir}" || exit
	fi
	"${steamcmdcommand}" +login "${steamuser}" "${steampass}" +app_info_print 17710 +quit > /dev/null 2>&1
	"${steamcmdcommand}" +login "${steamuser}" "${steampass}" +download_depot 17710 17711 +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
	ndcontentdepot="$(grep -o 'Depot download complete : "[^"]*"' "${steamcmdlog}" | tail -1 | cut -d'"' -f2 | tr '\134' '/')"
	if [[ "${ndcontentdepot}" == */depot_17711 ]]; then
		if [ -f "${ndcontentdepot}/nucleardawn/gameinfo.txt" ]; then
			tar -C "${ndcontentdepot}" -cf - . | tar -C "${serverfiles}" -xf - --skip-old-files
		fi
		rm -rf "${ndcontentdepot:?}" "${ndcontentdepot%/*}/state_17710_17711.patch"
	fi
	if [ -f "${serverfiles}/nucleardawn/gameinfo.txt" ]; then
		exitcode=0
	else
		exitcode=1
	fi
	fn_fix_msg_end
	if [ "${exitcode}" -ne 0 ]; then
		fn_print_nl "* Nuclear Dawn game content requires a Steam account that owns Nuclear Dawn."
		fn_print_nl "* Set steamuser and steampass in ${configdirserver}"
		core_exit.sh
	fi
fi

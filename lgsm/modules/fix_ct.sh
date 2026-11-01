#!/bin/bash
# LinuxGSM fix_ct.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Craftopia.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -f "${servercfgfullpath}" ]; then
	savepath="$(sed -n 's/^savePath=//p' "${servercfgfullpath}" | tr -d '\r')"
	if [ -n "${savepath}" ] && [ "${savepath:0:1}" != "/" ]; then
		oldsavedir="${serverfiles}${savepath%/}"
		newsavedir="${serverfiles}/${savepath%/}"
		if [ -e "${oldsavedir}" ] && [ -e "${newsavedir}" ]; then
			fn_print_warn_nl "Craftopia saves found in both ${oldsavedir} and ${newsavedir}"
			fn_script_log_warn "Craftopia saves found in both ${oldsavedir} and ${newsavedir}"
			echo -e "* Keep the one you want in ${newsavedir}, remove the other, then start again."
		else
			if [ -e "${oldsavedir}" ]; then
				fixname="move saves to ${newsavedir}"
				fn_fix_msg_start
				mkdir -p "$(dirname "${newsavedir}")"
				mv "${oldsavedir}" "${newsavedir}"
				exitcode=$?
				fn_fix_msg_end
			fi
			if [ ! -e "${oldsavedir}" ]; then
				fixname="savePath ${serverfiles}/${savepath}"
				fn_fix_msg_start
				sed -i "s|^savePath=[^\r]*|savePath=${serverfiles}/${savepath}|" "${servercfgfullpath}"
				exitcode=$?
				fn_fix_msg_end
			fi
		fi
	fi
fi

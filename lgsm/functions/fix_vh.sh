#!/bin/bash
# LinuxGSM fix_rust.sh function
# Author: Alasdair Haig
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Valheim

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH

# special check if Valheim Plus is installed
modsdir="${lgsmdir}/mods"
modsinstalledlistfullpath="${modsdir}/installed-mods.txt"
if [ -f "${modsinstalledlistfullpath}" ]; then
	if grep -qE "^valheimplus" "${modsinstalledlistfullpath}"
	then
		if ! grep -qE "^executable=\"./start_server_bepinex.sh\"" "${configdirserver}/${selfname}.cfg"
		then
			echo 'executable="./start_server_bepinex.sh"' >> "${configdirserver}/${selfname}.cfg"
			executable="./start_server_bepinex.sh"
		fi
	fi
fi

#!/bin/bash
# LinuxGSM fix_rust.sh module
# Author: Alasdair Haig
# Website: https://linuxgsm.com
# Description: Resolves issues with Valheim.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH

modsdir="${lgsmdir}/mods"
modsinstalledlistfullpath="${modsdir}/installed-mods.txt"
if [ -f "${modsinstalledlistfullpath}" ]; then
	# special check if Valheim Plus is installed
	if grep -qE "^valheimplus" "${modsinstalledlistfullpath}"; then
		if ! grep -qE "^executable=\"./start_server_bepinex.sh\"" "${configdirserver}/${selfname}.cfg"; then
			echo 'executable="./start_server_bepinex.sh"' >> "${configdirserver}/${selfname}.cfg"
			executable="./start_server_bepinex.sh"
		fi
	fi
	# special exports for BepInEx if installed
	if grep -qE "^bepinexvh" "${modsinstalledlistfullpath}"; then
		fn_print_info_nl "BepInEx install detected, applying start exports"
		fn_script_log_info "BepInEx install detected, applying start exports"
		# exports for BepInEx framework from script start_server_bepinex.sh
		export DOORSTOP_ENABLE=TRUE
		export DOORSTOP_INVOKE_DLL_PATH=./BepInEx/core/BepInEx.Preloader.dll
		export DOORSTOP_CORLIB_OVERRIDE_PATH=./unstripped_corlib

		export LD_LIBRARY_PATH="./doorstop_libs:${LD_LIBRARY_PATH}"
		export LD_PRELOAD="libdoorstop_x64.so:${LD_PRELOAD}"

		export SteamAppId=892970
	fi
fi

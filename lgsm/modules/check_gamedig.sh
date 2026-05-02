#!/bin/bash
# LinuxGSM check_gamedig.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Installs nodejs and gamedig

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "$(command -v node)" ] && [ "$(command -v npm)" ] && [ "$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)" -ge 16 ] && [ ! -f "${lgsmdir}/node_modules/gamedig/bin/gamedig.js" ]; then
	echo -e ""
	echo -e "${bold}${lightyellow}Installing Gamedig${default}"
	fn_script_log_info "Installing Gamedig"
	cd "${lgsmdir}" || exit
	curl -L -o package.json "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/package.json"
	npm install
elif [ "$(command -v node)" ] && [ "$(command -v npm)" ] && [ "$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)" -ge 16 ]; then
	cd "${lgsmdir}" || exit
	curl -s -L -o package.json "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/package.json"
	npm update > /dev/null 2>&1
fi

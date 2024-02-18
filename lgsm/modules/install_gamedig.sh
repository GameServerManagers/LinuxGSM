#!/bin/bash
# LinuxGSM install_gamedig.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Installs nodejs and gamedig

if [ "$(command -v node)" ] && [ ! -f "${lgsmdir}/node_modules/gamedig/bin/gamedig.js" ]; then
	cd "${lgsmdir}" || exit
	wget -N --no-check-certificate "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/${githubbranch}/package.json"
	npm install
fi

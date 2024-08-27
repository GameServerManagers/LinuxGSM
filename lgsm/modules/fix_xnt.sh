#!/bin/bash
# LinuxGSM fix_xnt.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Install Xonotic Default Config

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Create the directory if it doesn't exist
if [ ! -d "${serverfiles}/Xonotic/${selfname}/data" ]; then
	mkdir -p "${serverfiles}/Xonotic/${selfname}/data"
fi

# Copy the server.cfg file if it exists
if [ -f "${serverfiles}/Xonotic/server/server.cfg" ]; then
	cp "${serverfiles}/Xonotic/server/server.cfg" "${serverfiles}/Xonotic/${selfname}/data/server.cfg"
fi

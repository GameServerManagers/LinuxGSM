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

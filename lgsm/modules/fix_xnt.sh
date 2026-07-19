#!/bin/bash
# LinuxGSM fix_xnt.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Install Xonotic Default Config

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Create the directory if it doesn't exist
if [ ! -d "${systemdir}/${selfname}/data" ]; then
	mkdir -p "${systemdir}/${selfname}/data"
fi

#!/bin/bash
# LinuxGSM fix_av.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Avorion.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/linux64"

# Generates the server config if it doesn't exist.
if [ ! -f "${servercfgfullpath}" ]; then
	startparameters="--datapath ${avdatapath} --galaxy-name ${selfname} --init-folders-only"
	fn_print_information "starting ${gamename} server to generate configs."
	cd "${systemdir}" || exit
	eval "${executable} ${startparameters}"
fi

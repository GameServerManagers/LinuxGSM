#!/bin/bash
# LinuxGSM fix_av.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Avorion

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/linux64"

if [ "${postinstall}" == "1" ]; then
	startparameters="--datapath ${avdatapath} --galaxy-name ${selfname} --init-folders-only"
	fn_print_information "starting ${gamename} server to generate configs."
	fn_sleep_time
	# go to the executeable dir and start the init of the server
	cd "${systemdir}" || return 2
	"${executabledir}/${executable}" ${startparameters}
fi

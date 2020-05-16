#!/bin/bash
# LinuxGSM command_version.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Will run update-lgsm if gameserver.sh and modules version does not match
# this will allow gameserver.sh to update - useful for multi instance servers.

if [ "${version}" != "${modulesversion}" ]; then
	exitbypass=1
	command_update_linuxgsm.sh
fi

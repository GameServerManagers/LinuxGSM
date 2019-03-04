#!/bin/bash
# LinuxGSM fix_cfwf.sh function
# Author: Daniel Gibbs
# Contributor: BackInTheMatrix
# Website: https://linuxgsm.com
# Description: Resolves various issues with Citadel: Forged With Fire.

# Copy steamclient.so to Plugins folder to ensure that steam server launches.
if [ "$(diff "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/Citadel/Plugins/UWorks/Source/ThirdParty/Linux/steamclient.so" >/dev/null)" ]; then
	cp -f "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/Citadel/Plugins/UWorks/Source/ThirdParty/Linux/steamclient.so"
fi

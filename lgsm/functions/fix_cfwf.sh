#!/bin/bash
# LinuxGSM fix_cfwf.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Citadel: Forged With Fire.

# Check if steamclient.so is available in correct Plugins folder and copy if necessary.
if [ ! -f "${serverfiles}/Citadel/Plugins/UWorks/Source/ThirdParty/Linux/steamclient.so" ]; then
        cp -f "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/Citadel/Plugins/UWorks/Source/ThirdParty/Linux/steamclient.so"

# Verify version of steamclient and copy to Plugins folder if version mismatch.
elif [ "$(diff "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/Citadel/Plugins/UWorks/Source/ThirdParty/Linux/steamclient.so" >/dev/null)" ]; then
        cp -f "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/Citadel/Plugins/UWorks/Source/ThirdParty/Linux/steamclient.so"
fi
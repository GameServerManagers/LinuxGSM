#!/bin/bash
# LinuxGSM fix_cfwf.sh function
# Author: BackInTheMatrix
# Website: https://linuxgsm.com
# Description: Resolves various issues with Citadel: Forged With Fire.

# Copying steamclient.so to correct Plugins folder, to ensure steam server launches.
cp "${steamcmddir}/linux64/steamclient.so" "${serverfiles}/Citadel/Plugins/UWorks/Source/ThirdParty/Linux/steamclient.so"

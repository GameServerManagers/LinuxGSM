#!/bin/bash
# LinuxGSM fix_ark.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with ARK: Survival Evolved.

# removes the symlink if broken. fixes issue with older versions of LinuxGSM linking to /home/arkserver/steamcmd
# rather than ${HOME}/.steam. This fix could be deprecated eventually.
if [ ! -e "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux" ] ; then
	rm -f "${serverfiles:?}/Engine/Binaries/ThirdParty/SteamCMD/Linux"
fi

if [ ! -e "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps" ] ; then
	rm -f "${serverfiles:?}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps"
fi

# Symlinking the SteamCMD directory into the correct ARK directory so that the mods auto-management will work.
if [ ! -d "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux" ]; then
	ln -s "${HOME}/.steam/steamcmd" "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux"
fi

if [ ! -d "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps" ]; then
	ln -s "${HOME}/Steam/steamapps" "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps"
fi

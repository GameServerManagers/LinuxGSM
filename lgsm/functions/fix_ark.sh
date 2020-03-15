#!/bin/bash
# LinuxGSM fix_ark.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with ARK: Survival Evolved.

# removes the symlink if broken. fixes issue with older versions of LinuxGSM linking to /home/arkserver/steamcmd
# rather than ${HOME}/.steam. This fix could be deprecated eventually.
if [ ! -e "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux" ]||[ ! -e "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps" ]; then
	fixname="broken steamcmd symlink"
	fn_fix_msg_start
	rm -f "${serverfiles:?}/Engine/Binaries/ThirdParty/SteamCMD/Linux"
	rm -f "${serverfiles:?}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps"
	fn_fix_msg_end
fi

# Symlinking the SteamCMD directory into the correct ARK directory so that the mods auto-management will work.
if [ ! -d "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux" ]||[ ! -d "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps" ]; then
	fixname="steamcmd symlink"
	fn_fix_msg_start
	ln -s "${HOME}/.steam/steamcmd" "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux"
	ln -s "${HOME}/Steam/steamapps" "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps"
	fn_fix_msg_end
fi

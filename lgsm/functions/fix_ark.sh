#!/bin/bash
# LinuxGSM fix_ark.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with ARK: Survival Evolved.

# removes the symlink if broken. fixes issue with older versions of LinuxGSM linking to /home/arkserver/steamcmd
# rather than ${HOME}/.steam. This fix could be deprecated eventually.
if [ ! -e "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux" ]; then
	fixname="broken steamcmd symlink"
	fn_fix_msg_start
	rm -f "${serverfiles:?}/Engine/Binaries/ThirdParty/SteamCMD/Linux"
	fn_fix_msg_end
fi

if [ ! -e "${HOME}/.steam/steamcmd/steamapps" ]; then
	fixname="broken steamcmd symlink"
	fn_fix_msg_start
	rm -f "${HOME}/.steam/steamcmd/steamapps"
	fn_fix_msg_end
fi

# Symlinking the SteamCMD directory into the correct ARK directory so that the mods auto-management will work.
if [ ! -d "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux" ]; then
	fixname="steamcmd symlink"
	fn_fix_msg_start
	ln -s "${HOME}/.steam/steamcmd" "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux"
	fn_fix_msg_end
fi

if [ ! -d "${HOME}/.steam/steamcmd/steamapps" ]; then
	fixname="steamcmd symlink"
	fn_fix_msg_start
	ln -s "${HOME}/Steam/steamapps" "${HOME}/.steam/steamcmd/steamapps"
	fn_fix_msg_end
fi

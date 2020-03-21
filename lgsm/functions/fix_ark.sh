#!/bin/bash
# LinuxGSM fix_ark.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with ARK: Survival Evolved.

# removes the symlink if broken or does not match what is excpected.
# fixes issue with older versions of LinuxGSM linking to /home/arkserver/steamcmd
# rather than ${HOME}/.steam. This fix could be deprecated eventually.
if [ ! -e "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux" ]||[ "$(readlink ${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux)" != "${HOME}/.steam/steamcmd" ]; then
	fixname="broken SteamCMD symlink"
	fn_fix_msg_start
	unlink "${serverfiles:?}/Engine/Binaries/ThirdParty/SteamCMD/Linux"
	fn_fix_msg_end
fi

#if [ ! -e "${HOME}/.steam/steamcmd/SteamApps" ]||[ "$(readlink ${HOME}/.steam/steamcmd/SteamApps)" != "${HOME}/.steam/SteamApps" ]; then
#	fixname="broken SteamApps symlink"
#	fn_fix_msg_start
#	unlink "${HOME}/.steam/steamcmd/SteamApps"
#	fn_fix_msg_end
#fi

# Symlinking the SteamCMD directory into the correct ARK directory so that the mods auto-management will work.

# Put symlink to SteamCMD in to Linux dir
#if [ ! -d "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux" ]; then
#	fixname="steamcmd symlink"
#	fn_fix_msg_start
#	ln -s "${HOME}/.steam/steamcmd" "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux"
#	fn_fix_msg_end
#fi

# Put symlink to SteamApps dir in steamcmd dir
if [ ! -d "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps" ]; then
	fixname="steamcmd symlink"
	fn_fix_msg_start
	ln -s "${HOME}/Steam/steamapps" "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps"
	fn_fix_msg_end
fi

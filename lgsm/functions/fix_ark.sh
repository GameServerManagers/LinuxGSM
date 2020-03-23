#!/bin/bash
# LinuxGSM fix_ark.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with ARK: Survival Evolved.

# Steam mods directory selecter
# This allows LinxuGSM to select either ~/.steam or ~/Steam. depending on what is being used

steamappsfile=$(find ${HOME} -name appworkshop_346110.acf)
steamappsdir=$(dirname "${steamappsfile}")
steamappspath=$(cd ${steamappsdir};cd ../;pwd)

# removes the symlink if exists.
# fixes issue with older versions of LinuxGSM linking to /home/arkserver/steamcmd
if [ -L "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux" ]; then
	fixname="broken SteamCMD symlink"
	fn_fix_msg_start
	unlink "${serverfiles:?}/Engine/Binaries/ThirdParty/SteamCMD/Linux"
	fn_fix_msg_end
	check_steamcmd.sh
fi

# removed ARK steamcmd directory if steamcmd is missing.
if [ ! -f "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamcmd.sh" ]; then
	fixname="remove invalid ARK SteamCMD directory"
	fn_fix_msg_start
	rm -rf "${serverfiles:?}/Engine/Binaries/ThirdParty/SteamCMD/Linux"
	fn_fix_msg_end
	check_steamcmd.sh
fi

# if the steamapps symlink is incorrect unlink it.
if [ -d "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux" ]&&[ -L "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps" ]&&[ "$(readlink ${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps)" != "${steamappsdir}" ]; then
	fixname="incorrect steamapps symlink"
	fn_fix_msg_start
	unlink "${serverfiles:?}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps"
	fn_fix_msg_end
fi

# Put symlink to steamapps directory into the ARK SteamCMD directory to link the downloaded mods to the correct location.
if [ ! -L "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps" ]; then
	fixname="steamapps symlink"
	fn_fix_msg_start
	ln -s "${steamappspath}" "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps"
	fn_fix_msg_end
fi

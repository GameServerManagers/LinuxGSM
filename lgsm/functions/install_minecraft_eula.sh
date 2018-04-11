#!/bin/bash
# LinuxGSM install_minecraft_eula.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Gets user to accept the EULA.

echo ""
echo "Accept ${gamename} EULA"
echo "================================="
sleep 0.5
echo "You are required to accept the EULA:"
echo "https://account.mojang.com/documents/minecraft_eula"

echo "eula=false" > "${serverfiles}/eula.txt"

if [ -z "${autoinstall}" ]; then
echo "By continuing you are indicating your agreement to the EULA."
echo ""
	if ! fn_prompt_yn "Continue?" Y; then
		core_exit.sh
	fi
else
echo "By using auto-install you are indicating your agreement to the EULA."
echo ""
	sleep 5
fi

sed -i "s/eula=false/eula=true/g" "${serverfiles}/eula.txt"

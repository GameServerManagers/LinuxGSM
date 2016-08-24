#!/bin/bash
# LGSM install_minecraft_eula.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Gets user to accept the EULA.

echo ""
echo "Accept ${gamename} EULA"
echo "================================="
sleep 1
echo "You are required to accept the EULA:"
echo "https://account.mojang.com/documents/minecraft_eula"

echo "eula=false" > "${filesdir}/eula.txt"

if [ -z "${autoinstall}" ]; then
echo "By continuing you are indicating your agreement to the EULA."
echo ""
	while true; do
		read -e -i "y" -p "Continue [Y/n]" yn
		case $yn in
		[Yy]* ) break;;
		[Nn]* ) core_exit.sh;;
		* ) echo "Please answer yes or no.";;
		esac
	done
else
echo "By using auto-install you are indicating your agreement to the EULA."
echo ""
	sleep 5
fi

sed -i "s/eula=false/eula=true/g" "${filesdir}/eula.txt"
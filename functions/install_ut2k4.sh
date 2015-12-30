#!/bin/bash
# LGSM install_ut2k4.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

echo ""
echo "Installing ${gamename} Server"
echo "================================="
sleep 1
cd "${filesdir}"
echo "Extracting dedicatedserver3339-bonuspack.zip"
sleep 1
unzip dedicatedserver3339-bonuspack.zip
echo "Extracting ut2004-lnxpatch3369-2.tar.bz2"
sleep 1
tar -xvjf ut2004-lnxpatch3369-2.tar.bz2 UT2004-Patch/ --strip-components=1
while true; do
	read -p "Was the install successful? [y/N]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) install_retry.sh;;
	* ) echo "Please answer yes or no.";;
esac
done
while true; do
	read -p "Remove ut2004-lnxpatch3369-2.tar.bz2? [y/N]" yn
	case $yn in
	[Yy]* ) rm -fv ut2004-lnxpatch3369-2.tar.bz2; break;;
	[Nn]* ) break;;
	* ) echo "Please answer yes or no.";;
	esac
done
while true; do
	read -p "Remove dedicatedserver3339-bonuspack.zip? [y/N]" yn
	case $yn in
	[Yy]* ) rm -fv dedicatedserver3339-bonuspack.zip; break;;
	[Nn]* ) break;;
	* ) echo "Please answer yes or no.";;
	esac
done
echo ""
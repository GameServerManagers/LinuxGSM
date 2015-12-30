#!/bin/bash
# LGSM install_ut99.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

echo ""
echo "Installing ${gamename} Server"
echo "================================="
sleep 1
cd "${filesdir}"
echo "Extracting ut-server-436.tar.gz"
sleep 1
tar -zxvf ut-server-436.tar.gz ut-server/ --strip-components=1
echo "Extracting UTPGPatch451.tar.bz2"
sleep 1
tar -jxvf UTPGPatch451.tar.bz2
while true; do
	read -p "Was the install successful? [y/N]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) install_retry.sh;;
	* ) echo "Please answer yes or no.";;
esac
done
while true; do
	read -p "Remove ut-server-436.tar.gz? [y/N]" yn
	case $yn in
	[Yy]* ) rm -fv ut-server-436.tar.gz; break;;
	[Nn]* ) break;;
	* ) echo "Please answer yes or no.";;
	esac
done
while true; do
	read -p "Remove UTPGPatch451.tar.bz2? [y/N]" yn
	case $yn in
	[Yy]* ) rm -fv UTPGPatch451.tar.bz2; break;;
	[Nn]* ) break;;
	* ) echo "Please answer yes or no.";;
	esac
done
echo ""
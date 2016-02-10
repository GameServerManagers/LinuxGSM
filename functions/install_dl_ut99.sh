#!/bin/bash
# LGSM install_dl_ut99.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com

echo ""
echo "Downloading Server Files"
echo "================================="
sleep 1
cd "${filesdir}"
if [ ! -f ut-server-436.tar.gz ]; then
	wget http://gameservermanagers.com/files/ut99/ut-server-436.tar.gz
else
	echo "ut-server-436.tar.gz already downloaded!"
fi
echo "Running MD5 checksum to verify the file"
sleep 1
echo "MD5 checksum: 10cd7353aa9d758a075c600a6dd193fd"
md5check=$(md5sum ut-server-436.tar.gz|awk '{print $1;}')
echo "File returned: ${md5check}"
if [ "${md5check}" != "10cd7353aa9d758a075c600a6dd193fd" ]; then
	echo "MD5 checksum: FAILED!"
	read -p "Retry download? [y/N]" yn
	case $yn in
	[Yy]* ) rm -fv ut-server-436.tar.gz; fn_filesdl;;
	[Nn]* ) echo Exiting; exit;;
	* ) echo "Please answer yes or no.";;
	esac
else
	echo "MD5 checksum: PASSED"
fi
if [ ! -f UTPGPatch451.tar.bz2 ]; then
	wget http://gameservermanagers.com/files/ut99/UTPGPatch451.tar.bz2
else
	echo "UTPGPatch451.tar.bz2 already downloaded!"
fi
echo "Running MD5 checksum to verify the file"
sleep 1
echo "MD5 checksum: 77a735a78b1eb819042338859900b83b"
md5check=$(md5sum UTPGPatch451.tar.bz2|awk '{print $1;}')
echo "File returned: ${md5check}"
if [ "${md5check}" != "77a735a78b1eb819042338859900b83b" ]; then
	echo "MD5 checksum: FAILED!"
	read -p "Retry download? [y/N]" yn
	case $yn in
	[Yy]* ) rm -fv UTPGPatch451.tar.bz2; fn_filesdl;;
	[Nn]* ) echo Exiting; exit;;
	* ) echo "Please answer yes or no.";;
	esac
else
	echo "MD5 checksum: PASSED"
fi
echo ""
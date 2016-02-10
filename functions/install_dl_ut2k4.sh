#!/bin/bash
# LGSM install_dl_ut2k4.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com

echo ""
echo "Downloading Server Files"
echo "================================="
sleep 1
cd "${filesdir}"
if [ ! -f dedicatedserver3339-bonuspack.zip ]; then
	wget http://gameservermanagers.com/files/ut2004/dedicatedserver3339-bonuspack.zip
else
	echo "dedicatedserver3339-bonuspack.zip already downloaded!"
fi
echo "Running MD5 checksum to verify the file"
sleep 1
echo "MD5 checksum: d3f28c5245c4c02802d48e4f0ffd3e34"
md5check=$(md5sum dedicatedserver3339-bonuspack.zip|awk '{print $1;}')
echo "File returned: ${md5check}"
if [ "${md5check}" != "d3f28c5245c4c02802d48e4f0ffd3e34" ]; then
	echo "MD5 checksum: FAILED!"
	read -p "Retry download? [y/N]" yn
	case $yn in
	[Yy]* ) rm -fv dedicatedserver3339-bonuspack.zip; install_dl_ut2k4.sh;;
	[Nn]* ) echo Exiting; exit;;
	* ) echo "Please answer yes or no.";;
	esac
else
	echo "MD5 checksum: PASSED"
fi
if [ ! -f ut2004-lnxpatch3369-2.tar.bz2 ]; then
	wget http://gameservermanagers.com/files/ut2004/ut2004-lnxpatch3369-2.tar.bz2
else
	echo "ut2004-lnxpatch3369-2.tar.bz2 already downloaded!"
fi
echo "Running MD5 checksum to verify the file"
sleep 1
echo "MD5 checksum: 0fa447e05fe5a38e0e32adf171be405e"
md5check=$(md5sum ut2004-lnxpatch3369-2.tar.bz2|awk '{print $1;}')
echo "File returned: ${md5check}"
if [ "${md5check}" != "0fa447e05fe5a38e0e32adf171be405e" ]; then
	echo "MD5 checksum: FAILED!"
	read -p "Retry download? [y/N]" yn
	case $yn in
	[Yy]* ) rm -fv ut2004-lnxpatch3369-2.tar.bz2; install_dl_ut2k4.sh;;
	[Nn]* ) echo Exiting; exit;;
	* ) echo "Please answer yes or no.";;
	esac
else
	echo "MD5 checksum: PASSED"
fi
echo ""
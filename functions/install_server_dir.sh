#!/bin/bash
# LGSM install_serverdir.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

echo ""
echo "Server Directory"
echo "================================="
sleep 1
echo ""
pwd
echo ""
if [ -d "${filesdir}" ]; then
	fn_printwarningnl "A server is already installed here."
fi
if [ -z "${autoinstall}" ]; then	
	while true; do
		read -e -i "y" -p "Continue [y/N]" yn
		case $yn in
		[Yy]* ) break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
		esac
	done
fi
if [ ! -d "${filesdir}" ]; then
	mkdir -v "${filesdir}"
fi
sleep 1
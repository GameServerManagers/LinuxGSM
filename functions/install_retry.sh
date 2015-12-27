#!/bin/bash
# LGSM install_retry.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

while true; do
	read -e -i "y" -p "Retry install? [Y/n]" yn
	case $yn in
	[Yy]* ) command_install.sh; exit;;
	[Nn]* ) echo Exiting; exit;;
	* ) echo "Please answer yes or no.";;
	esac
done
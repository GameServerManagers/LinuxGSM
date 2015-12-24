#!/bin/bash
# LGSM fn_install_retry function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

while true; do
	read -e -i "y" -p "Retry install? [Y/n]" yn
	case $yn in
	[Yy]* ) fn_install; exit;;
	[Nn]* ) echo Exiting; exit;;
	* ) echo "Please answer yes or no.";;
	esac
done
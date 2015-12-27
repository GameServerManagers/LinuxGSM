#!/bin/bash
# LGSM check_root.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="261215"

if [ $(whoami) = "root" ]; then
	fn_printfailnl "Do NOT run this script as root!"
	exit 1
fi

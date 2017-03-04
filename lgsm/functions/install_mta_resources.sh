#!/bin/bash
# LinuxGSM install_mta_resources.sh function
# Author: Daniel Gibbs
# Contributor: ChaosMTA
# Website: https://gameservermanagers.com
# Description: Installs the libmysqlclient for database functions on the server and optionally installs default resources required to run the server

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_install_libmysqlclient16(){
	echo ""
	echo "Checking if libmysqlclient16 is installed"
	echo "================================="
	sleep 1
	if [ ! -f /usr/lib/libmysqlclient.so.16 ]; then
		fn_print_warn_nl "libmysqlclient16 not installed. Installing.."
		sleep 1
		sudo -v > /dev/null 2>&1
		if [ $? -eq 0 ]; then
    	fileurl="https://nightly.mtasa.com/files/modules/64/libmysqlclient.so.16"; filedir="${tmpdir}"; filename="libmysqlclient.so.16"; executecmd="executecmd" run="norun"; force="noforce"; md5="6c188e0f8fb5d7a29f4bc413b9fed6c2"
    	fn_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
			sudo mv ${tmpdir}/${filename} /usr/lib/${filename}
		else
			fn_print_fail_nl "Failed to install libmysqlclient16, $(whoami) does not have sudo access. Download it manually and place it in /usr/lib"
			sleep 1
		fi
	else
  	echo "libmysqlclient16 already installed."
	fi
}

fn_install_libmysqlclient16

fn_print_information_nl "Server is inoperable by default without resources, you can install default ones by running the command install-default-resources"
echo ""

#!/bin/bash
# LGSM core_dl.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="050216"

# Description: Deals with all downloads for LGSM.

# Downloads can be defined in code like so
# fn_dl "dl_filename" "dl_filepath" "dl_url" "dl_md5"
# fn_dl "file.tar.bz2" "/home/gameserver" "http://example.com/file.tar/bz2" "10cd7353aa9d758a075c600a6dd193fd"

fn_dl_md5(){
# Runs MD5 Check if available
if [ -n "${dl_md5}" ]; then
	echo -ne "verifying ${dl_filename} with MD5...\c"
	local md5check=$(md5sum "${dl_filepath}/${dl_filename}"|awk '{print $1;}')
	if [ "${md5check}" != "${dl_md5}" ]; then
		fn_printfaileol
		echo "${dl_filename} MD5 checksum: ${md5check}"
		echo -e "expected MD5 checksum: ${dl_md5}"
		while true; do
			read -e -i "y" -p "Retry download? [Y/n]" yn
			case $yn in
			[Yy]* ) retry_dl=1; fn_dl;;
			[Nn]* ) echo Exiting; exit 1;;
			* ) echo "Please answer yes or no.";;
		esac
		done	
	else
		fn_printokeol
	fi
fi	
}

fn_dl(){
# defines variables from other script file
dl_filename=$1
dl_filepath=$2
dl_url=$3
dl_md5=$4

if [ ! -f "${dl_filepath}/${dl_filename}" ]||[ -n "${retry_dl}" ]; then
	echo -ne "downloading ${dl_filename}..."
	dl=$(curl --progress-bar --fail -o "${dl_filepath}/${dl_filename}" "${dl_url}")
	exitcode=$?
	echo -ne "downloading ${dl_filename}...\c"
	if [ ${exitcode} -ne 0 ]; then
		fn_printfaileol
		echo -e "${dl_url}\n"
		exit ${exitcode}
	else
		fn_printokeol
	fi
else	
	echo -e "${dl_filename} already exists...\c"
	fn_dl_md5
	while true; do
		read -e -i "n" -p "Download again? [y/N]" yn
		case $yn in
		[Yy]* ) fn_dl; retry_dl=1;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
	done
fi	


fn_dl_md5
}


#!/bin/bash
# LGSM install_sourcemod.sh
# Author: Jared Ballou
# Website: http://gameservermanagers.com

# This downloads and installs the latest stable versions of MetaMod and SourceMod



# MetaMod
fn_install_metamod(){
	# Get installation path for MetaMod
	mm_path="${1:-"${systemdir}/addons/metamod"}"
	mm_root=$(cd "$(dirname $(dirname "${mm_path}"))" && pwd)
	if [ -e "${mm_path}" ]; then
		read -p "WARNING! MetaMod exists at ${mm_path}! OVERWRITE!? [y/N]: " input
		if [ "${input}" != "y" ] && [ "${input}" != "Y" ]; then return; fi
	fi
	# Download URL base
	mm_url_base="http://www.sourcemm.net/downloads/"
	# Get latest release file name
	echo "Getting latest MetaMod version..."
	mm_file_latest="$(curl -sL "${mm_url_base}" | grep -m1 -o "mmsource-[0-9\.a-zA-Z]*-linux\.tar\.gz")"
	mm_file="${cachedir}/${mm_file_latest}"
	# If file is not here, download it
	if [ ! -e "${mm_file}" ]; then
		echo -ne "Downloading ${mm_file_latest}... \c"
		# Get mirror URLs
		mm_file_urls="$(curl -sL "${mm_url_base}${mm_file_latest}" | grep -o -E 'href="http([^"#]+)mmsource-1.10.6-linux.tar.gz"' | cut -d'"' -f2)"
		# Try each mirror
		for url in $mm_file_urls; do
			# Download file
			curl -sL "${url}" -o "${mm_file}"
			# If file downloaded, exit loop
			if [ -e "${mm_file}" ]; then break; fi
		done
		if [ ! -e "${mm_file}" ]; then
			fn_colortext red FAILED
			exit 1
		else
			fn_colortext green DONE
		fi
	fi
	# Unzip MetaMod to addons
	tar -xzvpf "${mm_file}" -C "${mm_root}"
}
fn_install_sourcemod(){
	# Get installation path for SourceMod
	sm_path="${1:-"${systemdir}/addons/sourcemod"}"
	sm_root=$(cd "$(dirname $(dirname "${sm_path}"))" && pwd)
	if [ -e "${sm_path}" ]; then
		read -p "WARNING! SourceMod exists at ${sm_path}! OVERWRITE!? [y/N]: " input
		if [ "${input}" != "y" ] && [ "${input}" != "Y" ]; then return; fi
	fi
	# Install SourceMod to game server
	sm_major_version="1.7"
	sm_url_base="http://www.sourcemod.net/smdrop/${sm_major_version}/"
	sm_url_latest="${sm_url_base}sourcemod-latest-linux"
	sm_file_latest="$(curl -sL "${sm_url_latest}")"
	sm_url_file="${sm_url_base}${sm_file_latest}"
	sm_file="${cachedir}/${sm_file_latest}"
	if [ ! -e "${sm_file}" ]; then
		echo -ne "Downloading ${sm_file_latest}... \c"
		curl -sL "${sm_url_file}" -o "${sm_file}"
		if [ ! -e "${sm_file}" ]; then
			fn_colortext red FAILED
			exit 1
		else
			fn_colortext green DONE
		fi
	fi
	# Unzip SourceMod to addons
	tar -xzvpf "${sm_file}" -C "${sm_root}"
}
fn_install_metamod
fn_install_sourcemod

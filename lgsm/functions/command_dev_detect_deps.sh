#!/bin/bash
# LinuxGSM command_dev_detect_deps.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Detects dependencies the server binary requires.

local commandname="DEPS-DETECT"
local commandaction="Deps-Detect"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo "================================="
echo "Dependencies Checker"
echo "================================="
echo "Checking directory: "
echo "${serverfiles}"
if [ "$(command -v eu-readelf 2>/dev/null)" ]; then
	readelf=eu-readelf
elif [ "$(command -v readelf 2>/dev/null)" ]; then
	readelf=readelf
else
	echo "readelf/eu-readelf not installed"
fi
files=$(find "${serverfiles}" | wc -l)
find "${serverfiles}" -type f -print0 |
while IFS= read -r -d $'\0' line; do
	if [ "${readelf}" == "eu-readelf" ]; then
		${readelf} -d "${line}" 2>/dev/null | grep NEEDED| awk '{ print $4 }' | sed 's/\[//g;s/\]//g' >> "${tmpdir}/.depdetect_readelf"
	else
		${readelf} -d "${line}" 2>/dev/null | grep NEEDED | awk '{ print $5 }' | sed 's/\[//g;s/\]//g' >> "${tmpdir}/.depdetect_readelf"
	fi
	echo -n "${i} / ${files}" $'\r'
	((i++))
done

sort "${tmpdir}/.depdetect_readelf" |uniq >"${tmpdir}/.depdetect_readelf_uniq"

while read -r lib; do
	if [ "${lib}" == "libm.so.6" ]||[ "${lib}" == "libc.so.6" ]||[ "${lib}" == "libtcmalloc_minimal.so.4" ]||[ "${lib}" == "libpthread.so.0" ]||[ "${lib}" == "libdl.so.2" ]||[ "${lib}" == "libnsl.so.1" ]||[ "${lib}" == "libgcc_s.so.1" ]||[ "${lib}" == "librt.so.1" ]||[ "${lib}" == "ld-linux.so.2" ]; then
		echo "glibc.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "lib32gcc1" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "lib32gcc1" >> "${tmpdir}/.depdetect_debian_list"
	elif [ "${lib}" == "libstdc++.so.6" ]; then
		echo "libstdc++.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "libstdc++6:i386" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libstdc++6:i386" >> "${tmpdir}/.depdetect_debian_list"
	elif [ "${lib}" == "libstdc++.so.5" ]; then
		echo "compat-libstdc++-33.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "libstdc++5:i386" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libstdc++5:i386" >> "${tmpdir}/.depdetect_debian_list"
	elif [ "${lib}" == "libcurl-gnutls.so.4" ]; then
		echo "libcurl.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "libcurl4-gnutls-dev:i386" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libcurl4-gnutls-dev:i386" >> "${tmpdir}/.depdetect_debian_list"
	elif [ "${lib}" == "libspeex.so.1" ]||[ "${lib}" == "libspeexdsp.so.1" ]; then
		echo "speex.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "speex:i386" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "speex:i386" >> "${tmpdir}/.depdetect_debian_list"

	elif [ "${lib}" == "./libSDL-1.2.so.0" ]||[ "${lib}" == "libSDL-1.2.so.0" ]; then
		echo "SDL.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "libsdl1.2debian" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libsdl1.2debian" >> "${tmpdir}/.depdetect_debian_list"

	elif [ "${lib}" == "libtbb.so.2" ]; then
		echo "tbb.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "libtbb2" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libtbb2" >> "${tmpdir}/.depdetect_debian_list"

	elif [ "${lib}" == "libtier0.so" ]||[ "${lib}" == "libtier0_srv.so" ]||[ "${lib}" == "libvstdlib_srv.so" ]||[ "${lib}" == "Core.so" ]||[ "${lib}" == "libvstdlib.so" ]||[ "${lib}" == "libtier0_s.so" ]||[ "${lib}" == "Editor.so" ]||[ "${lib}" == "Engine.so" ]||[ "${lib}" == "liblua.so" ]||[ "${lib}" == "libsteam_api.so" ]||[ "${lib}" == "ld-linux-x86-64.so.2" ]||[ "${lib}" == "libPhysX3_x86.so" ]||[ "${lib}" == "libPhysX3Common_x86.so" ]||[ "${lib}" == "libPhysX3Cooking_x86.so" ]; then
		# Known shared libs what dont requires dependencies
		:
	else
		unknownlib=1
		echo "${lib}" >> "${tmpdir}/.depdetect_unknown"
	fi
done < "${tmpdir}/.depdetect_readelf_uniq"

sort "${tmpdir}/.depdetect_centos_list" | uniq >> "${tmpdir}/.depdetect_centos_list_uniq"
sort "${tmpdir}/.depdetect_ubuntu_list" | uniq >> "${tmpdir}/.depdetect_ubuntu_list_uniq"
sort "${tmpdir}/.depdetect_debian_list" | uniq >> "${tmpdir}/.depdetect_debian_list_uniq"
if [ "${unknownlib}" == "1" ]; then
	sort "${tmpdir}/.depdetect_unknown" | uniq >> "${tmpdir}/.depdetect_unknown_uniq"
fi

awk -vORS='' '{ print $1,$2 }' "${tmpdir}/.depdetect_centos_list_uniq" > "${tmpdir}/.depdetect_centos_line"
awk -vORS='' '{ print $1,$2 }' "${tmpdir}/.depdetect_ubuntu_list_uniq" > "${tmpdir}/.depdetect_ubuntu_line"
awk -vORS='' '{ print $1,$2 }' "${tmpdir}/.depdetect_debian_list_uniq" > "${tmpdir}/.depdetect_debian_line"
echo ""
echo ""
echo "Required Dependencies"
echo "================================="
echo "${executable}"
echo ""
echo "CentOS"
echo "================================="
cat "${tmpdir}/.depdetect_centos_line"
echo ""
echo ""
echo "Ubuntu"
echo "================================="
cat "${tmpdir}/.depdetect_ubuntu_line"
echo ""
echo ""
echo "Debian"
echo "================================="
cat "${tmpdir}/.depdetect_debian_line"
echo ""
if [ "${unknownlib}" == "1" ]; then
	echo ""
	echo "Unknown shared Library"
	echo "================================="
	cat "${tmpdir}/.depdetect_unknown"
fi
echo ""
echo "Required Librarys"
echo "================================="
sort "${tmpdir}/.depdetect_readelf" | uniq
echo -en "\n"
rm -f "${tmpdir}/.depdetect_centos_line"
rm -f "${tmpdir}/.depdetect_centos_list"
rm -f "${tmpdir}/.depdetect_centos_list_uniq"

rm -f "${tmpdir}/.depdetect_debian_line"
rm -f "${tmpdir}/.depdetect_debian_list"
rm -f "${tmpdir}/.depdetect_debian_list_uniq"

rm -f "${tmpdir}/.depdetect_ubuntu_line"
rm -f "${tmpdir}/.depdetect_ubuntu_list"
rm -f "${tmpdir}/.depdetect_ubuntu_list_uniq"

rm -f "${tmpdir}/.depdetect_readelf"
rm -f "${tmpdir}/.depdetect_readelf_uniq"
rm -f "${tmpdir}/.depdetect_unknown"
rm -f "${tmpdir}/.depdetect_unknown_uniq"

core_exit.sh
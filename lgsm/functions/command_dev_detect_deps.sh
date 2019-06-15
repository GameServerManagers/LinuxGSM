#!/bin/bash
# LinuxGSM command_dev_detect_deps.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Detects dependencies the server binary requires.

local commandname="DETECT-DEPS"
local commandaction="Detect-Deps"
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
	echo "${lib}"
	local libs_array=( libm.so.6 libc.so.6 libtcmalloc_minimal.so.4 libpthread.so.0 libdl.so.2 libnsl.so.1 libgcc_s.so.1 librt.so.1 ld-linux.so.2 libdbus-glib-1.so.2 libgio-2.0.so.0 libglib-2.0.so.0 libGL.so.1 libgobject-2.0.so.0 libnm-glib.so.4 libnm-util.so.2 )
	for lib_file in "${libs_array[@]}"
	do
		if [ "${lib}" == "${lib_file}" ]; then
			echo "glibc.i686" >> "${tmpdir}/.depdetect_centos_list"
			echo "lib32gcc1" >> "${tmpdir}/.depdetect_ubuntu_list"
			echo "lib32gcc1" >> "${tmpdir}/.depdetect_debian_list"
			libdetected=1
		fi
	done

	local libs_array=( libawt.so libjava.so libjli.so libjvm.so libnet.so libnio.so libverify.so )
	for lib_file in "${libs_array[@]}"
	do
		if [ "${lib}" == "${lib_file}" ]; then
			echo "java-1.8.0-openjdk" >> "${tmpdir}/.depdetect_centos_list"
			echo "default-jre" >> "${tmpdir}/.depdetect_ubuntu_list"
			echo "default-jre" >> "${tmpdir}/.depdetect_debian_list"
			libdetected=1
		fi
	done

	local libs_array=( libtier0.so libtier0_srv.so libvstdlib_srv.so Core.so libvstdlib.so libtier0_s.so Editor.so Engine.so liblua.so libsteam_api.so ld-linux-x86-64.so.2 libPhysX3_x86.so libPhysX3Common_x86.so libPhysX3Cooking_x86.so)
	for lib_file in "${libs_array[@]}"
	do
		# Known shared libs what dont requires dependencies.
		if [ "${lib}" == "${lib_file}" ]; then
			libdetected=1
		fi
	done

	if [ "${lib}" == "libstdc++.so.6" ]; then
		echo "libstdc++.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "libstdc++6:i386" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libstdc++6:i386" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libstdc++.so.5" ]; then
		echo "compat-libstdc++-33.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "libstdc++5:i386" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libstdc++5:i386" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libcurl-gnutls.so.4" ]; then
		echo "libcurl.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "libcurl4-gnutls-dev:i386" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libcurl4-gnutls-dev:i386" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libspeex.so.1" ]||[ "${lib}" == "libspeexdsp.so.1" ]; then
		echo "speex.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "speex:i386" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "speex:i386" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "./libSDL-1.2.so.0" ]||[ "${lib}" == "libSDL-1.2.so.0" ]; then
		echo "SDL.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "libsdl1.2debian" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libsdl1.2debian" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libtbb.so.2" ]; then
		echo "tbb.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo "libtbb2" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libtbb2" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1

	elif [ "${lib}" == "libXrandr.so.2" ]; then
		echo "libXrandr" >> "${tmpdir}/.depdetect_centos_list"
		echo "libxrandr2" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libxrandr2" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libXext.so.6" ]; then
		echo "libXext" >> "${tmpdir}/.depdetect_centos_list"
		echo "libxext6" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libxext6" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libXtst.so.6" ]; then
		echo "libXtst" >> "${tmpdir}/.depdetect_centos_list"
		echo "libxtst6" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libxtst6" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libpulse.so.0" ]; then
		echo "pulseaudio-libs" >> "${tmpdir}/.depdetect_centos_list"
		echo "libpulse0" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libpulse0" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libopenal.so.1" ]; then
		echo "" >> "${tmpdir}/.depdetect_centos_list"
		echo "libopenal1" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo "libopenal1" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	fi

	if [ "${libdetected}" != "1" ]; then
		unknownlib=1
		echo "${lib}" >> "${tmpdir}/.depdetect_unknown"
	fi
	unset libdetected
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

#!/bin/bash
# LinuxGSM command_dev_detect_deps.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Detects dependencies the server binary requires.

commandname="DEV-DETECT-DEPS"
commandaction="Dependency Checker"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_header
echo -e "Checking directory: "
echo -e "${serverfiles}"
if [ "$(command -v eu-readelf 2> /dev/null)" ]; then
	readelf=eu-readelf
elif [ "$(command -v readelf 2> /dev/null)" ]; then
	readelf=readelf
else
	echo -e "readelf/eu-readelf not installed"
fi
files=$(find "${serverfiles}" | wc -l)
find "${serverfiles}" -type f -print0 \
	| while IFS= read -r -d $'\0' line; do
		if [ "${readelf}" == "eu-readelf" ]; then
			${readelf} -d "${line}" 2> /dev/null | grep NEEDED | awk '{ print $4 }' | sed 's/\[//g;s/\]//g' >> "${tmpdir}/.depdetect_readelf"
		else
			${readelf} -d "${line}" 2> /dev/null | grep NEEDED | awk '{ print $5 }' | sed 's/\[//g;s/\]//g' >> "${tmpdir}/.depdetect_readelf"
		fi
		echo -n "${i} / ${files}" $'\r'
		((i++))
	done

sort "${tmpdir}/.depdetect_readelf" | uniq > "${tmpdir}/.depdetect_readelf_uniq"

touch "${tmpdir}/.depdetect_centos_list"
touch "${tmpdir}/.depdetect_ubuntu_list"
touch "${tmpdir}/.depdetect_debian_list"

while read -r lib; do
	echo -e "${lib}"
	libs_array=(libm.so.6 libc.so.6 libtcmalloc_minimal.so.4 libpthread.so.0 libdl.so.2 libnsl.so.1 libgcc_s.so.1 librt.so.1 ld-linux.so.2 libdbus-glib-1.so.2 libgio-2.0.so.0 libglib-2.0.so.0 libGL.so.1 libgobject-2.0.so.0 libnm-glib.so.4 libnm-util.so.2)
	for lib_file in "${libs_array[@]}"; do
		if [ "${lib}" == "${lib_file}" ]; then
			echo -e "glibc.i686" >> "${tmpdir}/.depdetect_centos_list"
			echo -e "lib32gcc1" >> "${tmpdir}/.depdetect_ubuntu_list"
			echo -e "lib32gcc1" >> "${tmpdir}/.depdetect_debian_list"
			libdetected=1
		fi
	done

	libs_array=(libawt.so libjava.so libjli.so libjvm.so libnet.so libnio.so libverify.so)
	for lib_file in "${libs_array[@]}"; do
		if [ "${lib}" == "${lib_file}" ]; then
			echo -e "java-1.8.0-openjdk" >> "${tmpdir}/.depdetect_centos_list"
			echo -e "default-jre" >> "${tmpdir}/.depdetect_ubuntu_list"
			echo -e "default-jre" >> "${tmpdir}/.depdetect_debian_list"
			libdetected=1
		fi
	done

	libs_array=(libtier0.so libtier0_srv.so libvstdlib_srv.so Core.so libvstdlib.so libtier0_s.so Editor.so Engine.so liblua.so libsteam_api.so ld-linux-x86-64.so.2 libPhysX3_x86.so libPhysX3Common_x86.so libPhysX3Cooking_x86.so)
	for lib_file in "${libs_array[@]}"; do
		# Known shared libs what dont requires dependencies.
		if [ "${lib}" == "${lib_file}" ]; then
			libdetected=1
		fi
	done

	if [ "${lib}" == "libstdc++.so.6" ]; then
		echo -e "libstdc++.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libstdc++6:i386" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libstdc++6:i386" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libstdc++.so.5" ]; then
		echo -e "compat-libstdc++-33.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libstdc++5:i386" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libstdc++5:i386" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libcurl-gnutls.so.4" ]; then
		echo -e "libcurl.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libcurl4-gnutls-dev:i386" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libcurl4-gnutls-dev:i386" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libspeex.so.1" ] || [ "${lib}" == "libspeexdsp.so.1" ]; then
		echo -e "speex.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "speex:i386" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "speex:i386" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "./libSDL-1.2.so.0" ] || [ "${lib}" == "libSDL-1.2.so.0" ]; then
		echo -e "SDL.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libsdl1.2debian" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libsdl1.2debian" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libtbb.so.2" ]; then
		echo -e "tbb.i686" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libtbb2" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libtbb2" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1

	elif [ "${lib}" == "libXrandr.so.2" ]; then
		echo -e "libXrandr" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libxrandr2" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libxrandr2" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libXext.so.6" ]; then
		echo -e "libXext" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libxext6" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libxext6" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libXtst.so.6" ]; then
		echo -e "libXtst" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libxtst6" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libxtst6" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libpulse.so.0" ]; then
		echo -e "pulseaudio-libs" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libpulse0" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libpulse0" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libopenal.so.1" ]; then
		echo -e "" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libopenal1" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libopenal1" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libgconf-2.so.4" ]; then
		echo -e "GConf2" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libgconf2-4" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libgconf2-4" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libz.so.1" ]; then
		echo -e "zlib" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "zlib1g" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "zlib1g" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libatk-1.0.so.0" ]; then
		echo -e "atk" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libatk1.0-0" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libatk1.0-0" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libcairo.so.2" ]; then
		echo -e "cairo" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libcairo2" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libcairo2" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libfontconfig.so.1" ]; then
		echo -e "fontconfig" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libfontconfig1" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libfontconfig1" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libfreetype.so.6" ]; then
		echo -e "freetype" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libfreetype6" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libfreetype6" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	elif [ "${lib}" == "libc++.so.1" ]; then
		echo -e "libcxx" >> "${tmpdir}/.depdetect_centos_list"
		echo -e "libc++1" >> "${tmpdir}/.depdetect_ubuntu_list"
		echo -e "libc++1" >> "${tmpdir}/.depdetect_debian_list"
		libdetected=1
	fi

	if [ "${libdetected}" != "1" ]; then
		unknownlib=1
		echo -e "${lib}" >> "${tmpdir}/.depdetect_unknown"
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
echo -e ""
echo -e ""
echo -e "${bold}Required Dependencies${default}"
fn_messages_separator
echo -e "${executable}"
echo -e ""
echo -e "${bold}CentOS"
fn_messages_separator
cat "${tmpdir}/.depdetect_centos_line"
echo -e ""
echo -e ""
echo -e "Ubuntu"
fn_messages_separator
cat "${tmpdir}/.depdetect_ubuntu_line"
echo -e ""
echo -e ""
echo -e "Debian"
fn_messages_separator
cat "${tmpdir}/.depdetect_debian_line"
echo -e ""
if [ "${unknownlib}" == "1" ]; then
	echo -e ""
	echo -e "Unknown shared Library"
	fn_messages_separator
	cat "${tmpdir}/.depdetect_unknown"
fi
echo -e ""
echo -e "Required Librarys"
fn_messages_separator
sort "${tmpdir}/.depdetect_readelf" | uniq
echo -en "\n"
rm -f "${tmpdir:?}/.depdetect_centos_line"
rm -f "${tmpdir:?}/.depdetect_centos_list"
rm -f "${tmpdir:?}/.depdetect_centos_list_uniq"

rm -f "${tmpdir:?}/.depdetect_debian_line"
rm -f "${tmpdir:?}/.depdetect_debian_list"
rm -f "${tmpdir:?}/.depdetect_debian_list_uniq"

rm -f "${tmpdir:?}/.depdetect_ubuntu_line"
rm -f "${tmpdir:?}/.depdetect_ubuntu_list"
rm -f "${tmpdir:?}/.depdetect_ubuntu_list_uniq"

rm -f "${tmpdir:?}/.depdetect_readelf"
rm -f "${tmpdir:?}/.depdetect_readelf_uniq"
rm -f "${tmpdir:?}/.depdetect_unknown"
rm -f "${tmpdir:?}/.depdetect_unknown_uniq"

core_exit.sh

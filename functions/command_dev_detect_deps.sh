#!/bin/bash
# LGSM fn_dep_detect function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: Detects dependencies the server binary requires.

local modulename="Backup"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
cd "${executabledir}"
if [ "${executable}" ==  "./hlds_run" ]; then
	executable=hlds_linux
elif [ "${executable}" ==  "./srcds_run" ]||[ "${executable}" ==  "./dabds.sh" ]||[ "${executable}" ==  "./srcds_run.sh" ]; then
	executable=srcds_linux
elif [ "${executable}" ==  "./server_linux32" ]; then
	executable=libSpark_Core.so
elif [ "${executable}" ==  "./runSam3_DedicatedServer.sh" ]; then
	executable=Sam3_DedicatedServer
elif [ "${executable}" ==  "./7DaysToDie.sh" ]; then
	executable=7DaysToDie.x86
elif [ "${executable}" ==  "./ucc-bin" ]; then
        
	if [ -f "${executabledir}/ucc-bin-real" ]; then
		executable=ucc-bin-real
	elif [ -f "${executabledir}/ut2004-bin" ]; then
		executable=ut2004-bin
	else
		executable=ut-bin
	fi

elif [ "${executable}" ==  "./ts3server_startscript.sh" ]; then
	executable=ts3server_linux_amd64	
fi

if [ -n "$(command -v eu-readelf)" ]; then
	readelf=eu-readelf
else
	readelf=readelf
fi

${readelf} -d ${executable} |grep NEEDED|awk '{ print $5 }'|sed 's/\[//g'|sed 's/\]//g' > "${lgsmdir}/.depdetect_readelf"


echo "yum install " > "${lgsmdir}/.depdetect_centos_list_uniq"
echo "apt-get install " > "${lgsmdir}/.depdetect_ubuntu_list_uniq"
echo "apt-get install " > "${lgsmdir}/.depdetect_debian_list_uniq"
while read lib; do
	sharedlib=${lib}
	if [ "${lib}" == "libm.so.6" ]||[ "${lib}" == "libc.so.6" ]||[ "${lib}" == "libpthread.so.0" ]||[ "${lib}" == "libdl.so.2" ]||[ "${lib}" == "libnsl.so.1" ]||[ "${lib}" == "libgcc_s.so.1" ]||[ "${lib}" == "librt.so.1" ]||[ "${lib}" == "ld-linux.so.2" ]; then
		echo "glibc.i686" >> "${lgsmdir}/.depdetect_centos_list"
		echo "lib32gcc1" >> "${lgsmdir}/.depdetect_ubuntu_list"
		echo "lib32gcc1" >> "${lgsmdir}/.depdetect_debian_list"
	
	elif [ "${lib}" == "libstdc++.so.6" ]; then
		echo "libstdc++.i686" >> "${lgsmdir}/.depdetect_centos_list"
		echo "libstdc++6:i386" >> "${lgsmdir}/.depdetect_ubuntu_list"
		echo "libstdc++6:i386" >> "${lgsmdir}/.depdetect_debian_list"
	
	elif [ "${lib}" == "libstdc++.so.5" ]; then
		echo "compat-libstdc++-33.i686" >> "${lgsmdir}/.depdetect_centos_list"
		echo "libstdc++5:i386" >> "${lgsmdir}/.depdetect_ubuntu_list"
		echo "libstdc++5:i386" >> "${lgsmdir}/.depdetect_debian_list"

	elif [ "${lib}" == "libspeex.so.1" ]||[ "${lib}" == "libspeexdsp.so.1" ]; then 
		echo "speex.i686" >> "${lgsmdir}/.depdetect_centos_list"
		echo "speex:i386" >> "${lgsmdir}/.depdetect_ubuntu_list"
		echo "speex:i386" >> "${lgsmdir}/.depdetect_debian_list"

	elif [ "${lib}" == "./libSDL-1.2.so.0" ]||[ "${lib}" == "libSDL-1.2.so.0" ]; then 
		echo "SDL.i686" >> "${lgsmdir}/.depdetect_centos_list"
		echo "libsdl1.2debian" >> "${lgsmdir}/.depdetect_ubuntu_list"
		echo "libsdl1.2debian" >> "${lgsmdir}/.depdetect_debian_list"		

	elif [ "${lib}" == "libtbb.so.2" ]; then 
		echo "tbb.i686" >> "${lgsmdir}/.depdetect_centos_list"
		echo "libtbb2" >> "${lgsmdir}/.depdetect_ubuntu_list"
		echo "libtbb2" >> "${lgsmdir}/.depdetect_debian_list"

	elif [ "${lib}" == "libtier0.so" ]||[ "${lib}" == "Core.so" ]||[ "${lib}" == "Editor.so" ]||[ "${lib}" == "Engine.so" ]||[ "${lib}" == "liblua.so" ]||[ "${lib}" == "libsteam_api.so" ]||[ "${lib}" == "ld-linux-x86-64.so.2" ]||[ "${lib}" == "libPhysX3_x86.so" ]||[ "${lib}" == "libPhysX3Common_x86.so" ]||[ "${lib}" == "libPhysX3Cooking_x86.so" ]; then
		# Known shared libs what dont requires dependencies
		:
	else
		unknownlib=1
		echo "${lib}" >> "${lgsmdir}/.depdetect_unknown"
	fi
done < "${lgsmdir}/.depdetect_readelf"
sort "${lgsmdir}/.depdetect_centos_list" | uniq >> "${lgsmdir}/.depdetect_centos_list_uniq"
sort "${lgsmdir}/.depdetect_ubuntu_list" | uniq >> "${lgsmdir}/.depdetect_ubuntu_list_uniq"
sort "${lgsmdir}/.depdetect_debian_list" | uniq >> "${lgsmdir}/.depdetect_debian_list_uniq"
if [ "${unknownlib}" == "1" ]; then
	sort "${lgsmdir}/.depdetect_unknown" | uniq >> "${lgsmdir}/.depdetect_unknown_uniq"
fi

awk -vORS=' ' '{ print $1, $2 }' "${lgsmdir}/.depdetect_centos_list_uniq" > "${lgsmdir}/.depdetect_centos_line"
awk -vORS=' ' '{ print $1, $2 }' "${lgsmdir}/.depdetect_ubuntu_list_uniq" > "${lgsmdir}/.depdetect_ubuntu_line"
awk -vORS=' ' '{ print $1, $2 }' "${lgsmdir}/.depdetect_debian_list_uniq" > "${lgsmdir}/.depdetect_debian_line"

echo ""
echo "Required Dependencies"
echo "================================="
echo "${executable}"
echo ""
echo "CentOS"
echo "================================="
cat "${lgsmdir}/.depdetect_centos_line"
echo ""
echo ""
echo "Ubuntu"
echo "================================="
cat "${lgsmdir}/.depdetect_ubuntu_line"
echo ""
echo ""
echo "Debian"
echo "================================="
cat "${lgsmdir}/.depdetect_debian_line"
echo ""
if [ "${unknownlib}" == "1" ]; then
	echo ""
	echo "Unknown shared Library"
	echo "================================="
	cat "${lgsmdir}/.depdetect_unknown"
fi
echo ""
echo "Required Librarys"
echo "================================="
sort "${lgsmdir}/.depdetect_readelf" |uniq
echo ""
echo "ldd"
echo "================================="
ldd ${executable}
echo -en "\n"
rm -f "${lgsmdir}/.depdetect_centos_line"
rm -f "${lgsmdir}/.depdetect_centos_list"
rm -f "${lgsmdir}/.depdetect_centos_list_uniq"

rm -f "${lgsmdir}/.depdetect_debian_line"
rm -f "${lgsmdir}/.depdetect_debian_list"
rm -f "${lgsmdir}/.depdetect_debian_list_uniq"

rm -f "${lgsmdir}/.depdetect_ubuntu_line"
rm -f "${lgsmdir}/.depdetect_ubuntu_list"
rm -f "${lgsmdir}/.depdetect_ubuntu_list_uniq"

rm -f "${lgsmdir}/.depdetect_readelf"

rm -f "${lgsmdir}/.depdetect_unknown"
rm -f "${lgsmdir}/.depdetect_unknown_uniq"

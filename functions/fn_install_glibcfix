#!/bin/bash
# LGSM fn_install_glibcfix function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

fn_glibcfixmsg(){
echo ""
echo "GLIBC Fix required"
echo "============================"
sleep 1
fn_printwarningnl "${gamename} requires GLIBC_${glibcversion} or above"
sleep 1
echo ""
echo -e "Currently installed:\e[0;31m GLIBC_$(ldd --version |grep ldd|awk '{print $NF}')\e[0;39m"
echo -e "Required: =>\e[0;32m GLIBC_${glibcversion}\e[0;39m"
echo ""
sleep 1
echo "The installer will now detect and download the required files to allow ${gamename} server to run on a distro with less than GLIBC_${glibcversion}."
echo "note: This will NOT upgrade GLIBC on your system."
echo ""
echo "http://gameservermanagers.com/glibcfix"
sleep 1
echo ""
echo -en "loading required files.\r"
sleep 1
echo -en "loading required files..\r"
sleep 1
echo -en "loading required files...\r"
sleep 1
echo -en "\n"
}

# if ldd command not detected
if [ -z $(command -v ldd) ]; then
	echo ""
	fn_printfailurenl "GLIBC is not detected"
	sleep 1
	echo "Install GLIBC and retry installation."
	sleep 1
	echo ""
	while true; do
		read -e -i "y" -p "Continue install? [Y/n]" yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) echo Exiting; exit;;
			 * ) echo "Please answer yes or no.";;
		esac
	done
# if Glibc less than 1.15
elif [ "$(ldd --version | sed -n '1 p' | tr -cd '[:digit:]' | tail -c 3)" -lt 215 ]; then
	# Blade Symphony
	if [ "${gamename}" == "Blade Symphony" ]; then
		glibcversion="2.15"
		fn_glibcfixmsg
		cp -v "${rootdir}/steamcmd/linux32/libstdc++.so.6" "${filesdir}/libstdc++.so.6"
	# Double Action: Boogaloo
	elif [ "${gamename}" == "Double Action: Boogaloo" ]; then
		glibcversion="2.15"
		fn_glibcfixmsg
		cd "${filesdir}"
		wget -nv -N https://github.com/dgibbs64/linuxgsm/blob/master/DoubleActionBoogaloo/dependencies/libm.so.6
	# Fistful of Frags
	elif [ "${gamename}" == "Fistful of Frags" ]; then
		glibcversion="2.15"
		fn_glibcfixmsg
		cd "${filesdir}"
		wget -nv -N https://github.com/dgibbs64/linuxgsm/raw/master/FistfulOfFrags/dependencies/libm.so.6
	# Garry's Mod
	elif [ "${gamename}" == "Garry's Mod" ]; then
		glibcversion="2.15"
		fn_glibcfixmsg
		cd "${filesdir}/bin"
		wget -nv -N https://github.com/dgibbs64/linuxgsm/raw/master/GarrysMod/dependencies/libc.so.6
		wget -nv -N https://github.com/dgibbs64/linuxgsm/raw/master/GarrysMod/dependencies/libm.so.6
		wget -nv -N https://github.com/dgibbs64/linuxgsm/raw/master/GarrysMod/dependencies/libpthread.so.0
		cp -v "${rootdir}/steamcmd/linux32/libstdc++.so.6" "${filesdir}/libstdc++.so.6"
	# Insurgency
	elif [ "${gamename}" == "Insurgency" ]; then
		glibcversion="2.15"
		fn_glibcfixmsg
		cd "${filesdir}/bin"
		wget -nv -N https://github.com/dgibbs64/linuxgsm/raw/master/Insurgency/dependencies/libc.so.6
		wget -nv -N https://github.com/dgibbs64/linuxgsm/raw/master/Insurgency/dependencies/libm.so.6
		wget -nv -N https://github.com/dgibbs64/linuxgsm/raw/master/Insurgency/dependencies/librt.so.1
		wget -nv -N https://github.com/dgibbs64/linuxgsm/raw/master/Insurgency/dependencies/libpthread.so.0
	elif [ "${gamename}" == "Left 4 Dead" ]; then
		glibcversion="2.07"
		fn_glibcfixmsg
		cp -v "${rootdir}/steamcmd/linux32/libstdc++.so.6" "${filesdir}/bin/libstdc++.so.6"
	# Natural Selection 2
	elif [ "${gamename}" == "Natural Selection 2" ]; then
		glibcversion="2.15"
		fn_glibcfixmsg
		cd "${filesdir}"
		wget -nv -N https://github.com/dgibbs64/linuxgsm/raw/master/NaturalSelection2/dependencies/libm.so.6
		cp -v "${rootdir}/steamcmd/linux32/libstdc++.so.6" "${filesdir}/libstdc++.so.6"
		# NS2: Combat
		elif [ "${gamename}" == "NS2: Combat" ]; then
			glibcversion="2.15"
			fn_glibcfixmsg
			cd "${filesdir}"
			wget -nv -N https://github.com/dgibbs64/linuxgsm/raw/master/NS2Combat/dependencies/libm.so.6
			cp -v "${rootdir}/steamcmd/linux32/libstdc++.so.6" "${filesdir}/libstdc++.so.6"
	# No More Room in Hell
	elif [ "${gamename}" == "No More Room in Hell" ]; then
		glibcversion="2.15"
		fn_glibcfixmsg
		cd "${filesdir}"
		wget -nv -N https://github.com/dgibbs64/linuxgsm/raw/master/NoMoreRoomInHell/dependencies/libm.so.6
		cp -v "${rootdir}/steamcmd/linux32/libstdc++.so.6" "${filesdir}/libstdc++.so.6"
	# if Glibc less than 1.13
	elif [ "$(ldd --version | sed -n '1 p' | tr -cd '[:digit:]' | tail -c 3)" -lt 213 ]; then
		# ARMA 3
		if [ "${gamename}" == "ARMA 3" ]; then
			glibcversion="2.13"
			fn_glibcfixmsg
			cp -v "${rootdir}/steamcmd/linux32/libstdc++.so.6" "${filesdir}/libstdc++.so.6"
		# Just Cause 2
		elif [ "${gamename}" == "Just Cause 2" ]; then
			glibcversion="2.13"
			fn_glibcfixmsg
			cp -v "${rootdir}/steamcmd/linux32/libstdc++.so.6" "${filesdir}/libstdc++.so.6"
		# Serious Sam 3: BFE
		elif [ "${gamename}" == "Serious Sam 3: BFE" ]; then
			glibcversion="2.13"
			fn_glibcfixmsg
			cp -v "${rootdir}/steamcmd/linux32/libstdc++.so.6" "${filesdir}/Bin/libstdc++.so.6"
		else
			: # Else glibcfix not required.
		fi
	else
		: #Else glibcfix not required.
	fi
fi
sleep 1

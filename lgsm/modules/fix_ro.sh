#!/bin/bash
# LinuxGSM fix_ro.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Red Orchestra: Ostfront 41-45.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# echo -e "applying WebAdmin ROOst.css fix."
# echo -e "http://forums.tripwireinteractive.com/showpost.php?p=585435&postcount=13"
sed -i 's/none}/none;/g' "${serverfiles}/Web/ServerAdmin/ROOst.css"
sed -i 's/underline}/underline;/g' "${serverfiles}/Web/ServerAdmin/ROOst.css"
# echo -e "applying WebAdmin CharSet fix."
# echo -e "http://forums.tripwireinteractive.com/showpost.php?p=442340&postcount=1"
sed -i 's/CharSet="iso-8859-1"/CharSet="utf-8"/g' "${systemdir}/uweb.int"

# get md5sum of steamclient.so
if [ -f "${serverfiles}/system/steamclient.so" ]; then
	steamclientmd5=$(md5sum "${serverfiles}/system/steamclient.so" | awk '{print $1;}')
fi
#get md5sum of libtier0_s.so
if [ -f "${serverfiles}/system/libtier0_s.so" ]; then
	libtier0_smd5=$(md5sum "${serverfiles}/system/libtier0_s.so" | awk '{print $1;}')
fi
#get md5sum of libvstdlib_s.so
if [ -f "${serverfiles}/system/libvstdlib_s.so" ]; then
	libvstdlib_smd5=$(md5sum "${serverfiles}/system/libvstdlib_s.so" | awk '{print $1;}')
fi

# get md5sum of steamclient.so from steamcmd
if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
	steamcmdsteamclientmd5=$(md5sum "${HOME}/.steam/steamcmd/linux32/steamclient.so" | awk '{print $1;}')
elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
	steamcmdsteamclientmd5=$(md5sum "${steamcmddir}/linux32/steamclient.so" | awk '{print $1;}')
elif [ -f "${HOME}/.local/share/Steam/steamcmd/linux32/steamclient.so" ]; then
	steamcmdsteamclientmd5=$(md5sum "${HOME}/.local/share/Steam/steamcmd/linux32/steamclient.so" | awk '{print $1;}')
fi

# get md5sum of libtier0_s.so from steamcmd
if [ -f "${HOME}/.steam/steamcmd/linux32/libtier0_s.so" ]; then
	steamcmdlibtier0_smd5=$(md5sum "${HOME}/.steam/steamcmd/linux32/libtier0_s.so" | awk '{print $1;}')
elif [ -f "${steamcmddir}/linux32/libtier0_s.so" ]; then
	steamcmdlibtier0_smd5=$(md5sum "${steamcmddir}/linux32/libtier0_s.so" | awk '{print $1;}')
elif [ -f "${HOME}/.local/share/Steam/steamcmd/linux32/libtier0_s.so" ]; then
	steamcmdlibtier0_smd5=$(md5sum "${HOME}/.local/share/Steam/steamcmd/linux32/libtier0_s.so" | awk '{print $1;}')
fi

# get md5sum of libvstdlib_s.so from steamcmd
if [ -f "${HOME}/.steam/steamcmd/linux32/libvstdlib_s.so" ]; then
	steamcmdlibvstdlib_smd5=$(md5sum "${HOME}/.steam/steamcmd/linux32/libvstdlib_s.so" | awk '{print $1;}')
elif [ -f "${steamcmddir}/linux32/libvstdlib_s.so" ]; then
	steamcmdlibvstdlib_smd5=$(md5sum "${steamcmddir}/linux32/libvstdlib_s.so" | awk '{print $1;}')
elif [ -f "${HOME}/.local/share/Steam/steamcmd/linux32/libvstdlib_s.so" ]; then
	steamcmdlibvstdlib_smd5=$(md5sum "${HOME}/.local/share/Steam/steamcmd/linux32/libvstdlib_s.so" | awk '{print $1;}')
fi

if [ ! -f "${serverfiles}/system/steamclient.so" ] || [ "${steamcmdsteamclientmd5}" != "${steamclientmd5}" ]; then
	fixname="steamclient.so x86"
	fn_fix_msg_start
	if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${serverfiles}/system/steamclient.so"
	elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
		cp "${steamcmddir}/linux32/steamclient.so" "${serverfiles}/system/steamclient.so"
	elif [ -f "${HOME}/.local/share/Steam/steamcmd/linux32/steamclient.so" ]; then
		cp "${HOME}/.local/share/Steam/steamcmd/linux32/steamclient.so" "${serverfiles}/system/steamclient.so"
	fi
	fn_fix_msg_end
fi

if [ ! -f "${serverfiles}/system/libtier0_s.so" ] || [ "${steamcmdlibtier0_smd5}" != "${libtier0_smd5}" ]; then
	fixname="libtier0_s.so"
	fn_fix_msg_start
	if [ -f "${HOME}/.steam/steamcmd/linux32/libtier0_s.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux32/libtier0_s.so" "${serverfiles}/system/libtier0_s.so"
	elif [ -f "${steamcmddir}/linux32/libtier0_s.so" ]; then
		cp "${steamcmddir}/linux32/libtier0_s.so" "${serverfiles}/system/libtier0_s.so"
	elif [ -f "${HOME}/.local/share/Steam/steamcmd/linux32/libtier0_s.so" ]; then
		cp "${HOME}/.local/share/Steam/steamcmd/linux32/libtier0_s.so" "${serverfiles}/system/libtier0_s.so"
	fi
	fn_fix_msg_end
fi

if [ ! -f "${serverfiles}/system/libvstdlib_s.so" ] || [ "${steamcmdlibvstdlib_smd5}" != "${libvstdlib_smd5}" ]; then
	fixname="libvstdlib_s.so"
	fn_fix_msg_start
	if [ -f "${HOME}/.steam/steamcmd/linux32/libvstdlib_s.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux32/libvstdlib_s.so" "${serverfiles}/system/libvstdlib_s.so"
	elif [ -f "${steamcmddir}/linux32/libvstdlib_s.so" ]; then
		cp "${steamcmddir}/linux32/libvstdlib_s.so" "${serverfiles}/system/libvstdlib_s.so"
	elif [ -f "${HOME}/.local/share/Steam/steamcmd/linux32/libvstdlib_s.so" ]; then
		cp "${HOME}/.local/share/Steam/steamcmd/linux32/libvstdlib_s.so" "${serverfiles}/system/libvstdlib_s.so"
	fi
	fn_fix_msg_end
fi

# if running install command
if [ "${commandname}" == "INSTALL" ]; then
	echo -e "applying server name fix."
	fn_sleep_time
	echo -e "forcing server restart..."
	fn_sleep_time
	exitbypass=1
	command_start.sh
	fn_firstcommand_reset
	fn_sleep_time_5
	exitbypass=1
	command_stop.sh
	fn_firstcommand_reset
	exitbypass=1
	command_start.sh
	fn_firstcommand_reset
	fn_sleep_time_5
	exitbypass=1
	command_stop.sh
	fn_firstcommand_reset
fi

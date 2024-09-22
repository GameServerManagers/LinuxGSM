#!/bin/bash
# LinuxGSM command_dev_detect_ldd.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Automatically detects required deps using ldd.
# Can check a file or directory recursively.

commandname="DEV-DETECT-LDD"
commandaction="Developer detect ldd"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_messages_separator
echo -e "Shared Object dependencies Checker"
fn_messages_separator

if [ -z "${serverfiles}" ]; then
	dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
fi

if [ -d "${serverfiles}" ]; then
	echo -e "Checking directory: "
	echo -e "${serverfiles}"
elif [ -f "${serverfiles}" ]; then
	echo -e "Checking file: "
	echo -e "${serverfiles}"
fi
echo -e ""
touch "${tmpdir}/detect_ldd.tmp"
touch "${tmpdir}/detect_ldd_not_found.tmp"

files=$(find "${serverfiles}" | wc -l)
find "${serverfiles}" -type f -print0 \
	| while IFS= read -r -d $'\0' line; do
		if ldd "${line}" 2> /dev/null | grep -v "not a dynamic executable"; then
			echo -e "${line}" >> "${tmpdir}/detect_ldd.tmp"
			ldd "${line}" 2> /dev/null | grep -v "not a dynamic executable" >> "${tmpdir}/detect_ldd.tmp"
			if ldd "${line}" 2> /dev/null | grep -v "not a dynamic executable" | grep "not found"; then
				echo -e "${line}" >> "${tmpdir}/detect_ldd_not_found.tmp"
				ldd "${line}" 2> /dev/null | grep -v "not a dynamic executable" | grep "not found" >> "${tmpdir}/detect_ldd_not_found.tmp"
			fi
		fi
		echo -n "$i / $files" $'\r'
		((i++))
	done
echo -e ""
echo -e ""
echo -e "All"
fn_messages_separator
cat "${tmpdir}/detect_ldd.tmp"

echo -e ""
echo -e "Not Found"
fn_messages_separator
cat "${tmpdir}/detect_ldd_not_found.tmp"

rm -f "${tmpdir:?}/detect_ldd.tmp"
rm -f "${tmpdir:?}/detect_ldd_not_found.tmp"

core_exit.sh

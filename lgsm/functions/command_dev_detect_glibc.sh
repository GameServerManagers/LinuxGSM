#!/bin/bash
# LinuxGSM command_dev_detect_glibc.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Automatically detects the version of GLIBC that is required.
# Can check a file or directory recursively.

local commandname="DETECT-GLIBC"
local commandaction="Detect-Glibc"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo "================================="
echo "GLIBC Requirements Checker"
echo "================================="

if [ -z "$(command -v objdump)" ]; then
	fn_print_failure_nl "objdump is missing"
	fn_script_log_fatal "objdump is missing"
	core_exit.sh
fi

if [ -z "${serverfiles}" ]; then
	dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
fi

if [ -d "${serverfiles}" ]; then
	echo "Checking directory: "
	echo "${serverfiles}"
elif [ -f "${serverfiles}" ]; then
	echo "Checking file: "
	echo "${serverfiles}"
fi
echo ""

files=$(find "${serverfiles}" | wc -l)
find "${serverfiles}" -type f -print0 |
while IFS= read -r -d $'\0' line; do
	glibcversion=$(objdump -T "${line}" 2>/dev/null | grep -oP "GLIBC[^ ]+" | grep -v GLIBCXX | sort | uniq | sort -r --version-sort | head -n 1)
	if [ "${glibcversion}" ]; then
		echo "${glibcversion}: ${line}" >>"${tmpdir}/detect_glibc_files.tmp"
	fi
	objdump -T "${line}" 2>/dev/null | grep -oP "GLIBC[^ ]+" >>"${tmpdir}/detect_glibc.tmp"
	echo -n "${i} / ${files}" $'\r'
	((i++))
done
if [ -f "${tmpdir}/detect_glibc_files.tmp" ]; then
	echo ""
	cat "${tmpdir}/detect_glibc_files.tmp"
	echo ""
	cat "${tmpdir}/detect_glibc.tmp" | sort | uniq | sort -r --version-sort
	rm "${tmpdir}/detect_glibc.tmp"
	rm "${tmpdir}/detect_glibc_files.tmp"
else
	fn_print_information_nl "GLIBC is not required"
fi
core_exit.sh

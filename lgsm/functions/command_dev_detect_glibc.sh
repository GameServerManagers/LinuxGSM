#!/bin/bash
# LinuxGSM command_dev_detect_glibc.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Automatically detects the version of GLIBC that is required.
# Can check a file or directory recursively.

echo "================================="
echo "GLIBC Requirements Checker"
echo "================================="

if [ -z "$(command -v objdump)" ]; then
	fn_print_failure_nl "objdump is missing"
	fn_script_log_fatal "objdump is missing"
	core_exit.sh
fi

if [ -d "${filesdir}" ]; then
	echo "Checking directory: "
	echo "${filesdir}"
elif [ -f "${filesdir}" ]; then
	echo "Checking file: "
	echo "${filesdir}"
fi
echo ""

files=$(find ${filesdir} | wc -l)
find "${filesdir}" -type f -print0 |
while IFS= read -r -d $'\0' line; do
	glibcversion=$(objdump -T "${line}" 2>/dev/null|grep -oP "GLIBC[^ ]+" |grep -v GLIBCXX|sort|uniq|sort -r --version-sort| head -n 1)
	if [ "${glibcversion}" ];then
		echo "${glibcversion}: ${line}" >>"${tmpdir}/detect_glibc_files.tmp"
	fi
	objdump -T "${line}" 2>/dev/null|grep -oP "GLIBC[^ ]+" >>"${tmpdir}/detect_glibc.tmp"
	echo -n "${i} / ${files}" $'\r'
	((i++))
done
echo ""
cat "${tmpdir}/detect_glibc_files.tmp"
echo ""
cat "${tmpdir}/detect_glibc.tmp"|sort|uniq|sort -r --version-sort
rm "${tmpdir}/detect_glibc.tmp"
rm "${tmpdir}/detect_glibc_files.tmp"

core_exit.sh

#!/bin/bash
# command_dev_detect_glibc.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Automatically detects the version of GLIBC that is required.
# Can check a file or directory recursively.

echo "================================="
echo "GLIBC Requirements Checker"
echo "================================="

if [ -z "${filesdir}" ]; then
	dir="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
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
find ${filesdir} -type f -print0 |
while IFS= read -r -d $'\0' line; do
	objdump -T $line 2>/dev/null|grep -oP "GLIBC[^ ]+" >>"${lgsmdir}/tmp/detect_glibc.tmp"
	echo -n "$i / $files" $'\r'
	((i++))
done
echo ""
cat "${lgsmdir}/tmp/detect_glibc.tmp"|sort|uniq|sort -r --version-sort
rm "${lgsmdir}/tmp/detect_glibc.tmp"
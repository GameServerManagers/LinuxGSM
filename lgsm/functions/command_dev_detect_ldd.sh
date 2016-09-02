#!/bin/bash
# command_dev_detect_ldd.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Automatically detects required deps using ldd.
# Can check a file or directory recursively.

echo "================================="
echo "LDD Requirements Checker"
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

find ${filesdir} -type f -print0 |
while IFS= read -r -d $'\0' line; do
	ldd $line |grep "=>" >>"${lgsmdir}/tmp/detect_ldd.tmp"
done

cat "${lgsmdir}/tmp/detect_ldd.tmp"|sort|uniq|sort -r --version-sort
rm "${lgsmdir}/tmp/detect_ldd.tmp"
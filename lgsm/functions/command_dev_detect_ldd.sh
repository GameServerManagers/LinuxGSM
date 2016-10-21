#!/bin/bash
# command_dev_detect_ldd.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Automatically detects required deps using ldd.
# Can check a file or directory recursively.

echo "================================="
echo "Shared Object dependencies Checker"
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
	#ldd -v $line 2>/dev/null|grep "=>" >>"${tmpdir}/detect_ldd.tmp"
	if [ -n "$(ldd $line 2>/dev/null |grep -v "not a dynamic executable")" ]; then
		echo "$line" >> "${tmpdir}/detect_ldd.tmp"
		ldd $line 2>/dev/null |grep -v "not a dynamic executable" >> "${tmpdir}/detect_ldd.tmp"

		if [ -n "$(ldd $line 2>/dev/null |grep -v "not a dynamic executable"|grep "not found")" ]; then
			echo "$line" >> "${tmpdir}/detect_ldd_not_found.tmp"
			ldd $line 2>/dev/null |grep -v "not a dynamic executable"|grep "not found" >> "${tmpdir}/detect_ldd_not_found.tmp"
		fi
	fi
	echo -n "$i / $files" $'\r'
	((i++))
done
echo ""
echo ""
echo "All"
echo "================================="
cat "${tmpdir}/detect_ldd.tmp"

echo ""
echo "Not Found"
echo "================================="
cat "${tmpdir}/detect_ldd_not_found.tmp"

rm "${tmpdir}/detect_ldd.tmp"
rm "${tmpdir}/detect_ldd_not_found.tmp"
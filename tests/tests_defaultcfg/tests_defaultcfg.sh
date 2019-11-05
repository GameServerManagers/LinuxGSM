#!/bin/bash

echo -e ""
echo -e "1.0 - Master Comparison"
echo -e "=================================================================="
echo -e "Description:"
echo -e "test checks that vars present in ALL _default.cfg files are correct."
echo -e ""
ls -al ../../
ls -al ../
ls -al .
find ../../lgsm/config-default/config-lgsm/ -name "*.cfg" -type f -print0 |
while IFS= read -r -d $'\0' line; do
	grep = ${line}  | cut -f1 -d"=" > defaultcfgtemp.txt
	diffoutput=$(diff defaultcfg_0.txt  defaultcfgtemp.txt | grep '^<')
	if [ "${diffoutput}" ]; then
		echo "File with errors:"
	       	echo "${line}"
		echo -e "================================="
		echo "${diffoutput}"
		echo ""
	fi
	rm defaultcfgtemp.txt
done

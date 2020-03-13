#!/bin/bash
echo -e ""
echo -e "0.1 - Full comparison Output"
echo -e "=================================================================="
echo -e "Description:"
echo -e "test checks that vars present in ALL _default.cfg files are correct."
echo -e ""
echo -e "In master config < | > In game config"
find "lgsm/config-default/config-lgsm/" ! -name '*template.cfg' -name "*.cfg" -type f -print0 |
while IFS= read -r -d $'\0' line; do
	grep "=" "${line}"  | cut -f1 -d"=" > defaultcfgtemp.txt
	diffoutput=$(diff tests/tests_defaultcfg/defaultcfg_0.txt  defaultcfgtemp.txt)
	if [ "${diffoutput}" ]; then
		echo "File with errors:"
		echo "${line}"
		echo -e "================================="
		echo -e "In master config < | > In game config"
		echo "${diffoutput}"
		echo ""
	fi
	rm -f defaultcfgtemp.txt
done

echo -e ""
echo -e "1.0 - Master Comparison"
echo -e "=================================================================="
echo -e "Description:"
echo -e "test checks that vars present in ALL _default.cfg files are correct."
echo -e ""
echo -e "In master config < | > In game config"
find lgsm/config-default/config-lgsm/ ! -name '*template.cfg' -name "*.cfg" -type f -print0 |
while IFS= read -r -d $'\0' line; do
	grep "=" "${line}" | cut -f1 -d"=" > defaultcfgtemp.txt
	diffoutput=$(diff tests/tests_defaultcfg/defaultcfg_0.txt  defaultcfgtemp.txt | grep '^<')
	if [ "${diffoutput}" ]; then
		echo "File with errors:"
		echo "${line}"
		echo -e "================================="
		echo -e "In master config < | > In game config"
		echo "${diffoutput}"
		echo ""
	fi
	rm -f defaultcfgtemp.txt
done

echo -e ""
echo -e "2.0 - Check Comment"
echo -e "=================================================================="
echo -e "Description:"
echo -e "test checks that comments in ALL _default.cfg files are correct."
echo -e ""
echo -e "In master config < | > In game config"
find lgsm/config-default/config-lgsm/ ! -name '*template.cfg' -name "*.cfg" -type f -print0 |
while IFS= read -r -d $'\0' line; do
	grep "#" "${line}"  > defaultcfgtemp.txt
	diffoutput=$(diff tests/tests_defaultcfg/defaultcfg_1.txt  defaultcfgtemp.txt | grep '^<')
	if [ "${diffoutput}" ]; then
		echo "File with errors:"
		echo "${line}"
		echo -e "================================="
		echo "${diffoutput}"
		echo ""
	fi
	rm -f defaultcfgtemp.txt
done

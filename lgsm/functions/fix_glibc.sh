#!/bin/bash
# LGSM fix_glibc.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="020116"

info_glibc.sh

if [ $(printf '%s\n$glibc_required\n' $glibc_version | sort -V | head -n 1) != $glibc_required ]; then
	echo "Version $(ldd --version | sed -n '1s/.* //p') is lower than $glibc_required"
	if [ ${glibcfix} == "yes" ]; then 
		export LD_LIBRARY_PATH=:${lgsmdir}/lib/ubuntu12.04/i386
	else
		echo "no glibc fix available you need to upgrade bro!!"
	fi	
else
	echo "GLIBC is OK no fix required"
fi
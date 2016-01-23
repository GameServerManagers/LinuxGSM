#!/bin/bash
# LGSM check_deps.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="170116"

# Description: Checks that the require dependencies are installed for LGSM


fn_deps_detector(){
# Checks is dependency is missing
if [ -n "$(command -v dpkg-query)" ]; then
	dpkg-query -W -f='${Status}' ${deptocheck} | grep -q -P '^install ok installed$'
	depstatus=$?
	if [ "${depstatus}" == "0" ]; then
		missingdep=0
		echo -en " \e[0;32m${deptocheck}\e[0m"
	else
		# if missing dependency is flagged
		missingdep=1
		echo -en " \e[0;31m${deptocheck}\e[0m"
	fi
	sleep 0.5
fi

# Add missing dependencies are added to array_deps_missing array
if [ "${missingdep}" == "1" ]; then
	array_deps_missing+=("${deptocheck}")
fi
}

fn_deps_email(){
# Adds postfix to required dependencies if email notification is enabled
if [ "${emailnotification}" == "on" ]; then
	array_deps_required+=("mailutils postfix")
fi
}


cd "${executabledir}"
# Generate array of missing deps
array_deps_missing=()
fn_printdots "Checking for missing dependencies:"
if [ "${executable}" ==  "./srcds_run" ]||[ "${executable}" ==  "./dabds.sh" ]||[ "${executable}" ==  "./srcds_run.sh" ]||[ "${executable}" ==  "./Jcmp-Server" ] ; then
	local array_deps_required=( tmux curl lib32gcc1 libstdc++6:i386 )
	fn_deps_email
elif 	
else
	fn_printfail "Unknown executable"
	exit	
fi

# Loop though required depenencies
for deptocheck in "${array_deps_required[@]}"
do
	fn_deps_detector
done

if [ "${#array_deps_missing[@]}" != "0" ]; then
	fn_printwarnnl "Dependency Missing: \e[0;31m${array_deps_missing[@]}\e[0m"
	sleep 2
	sudo -n true
	if [ $? -eq 0 ]; then
		fn_printinfonl "Attempting to install missing dependencies automatically"
		echo -en ".\r"
		sleep 1
		echo -en "..\r"
		sleep 1
		echo -en "...\r"
		sleep 1
		echo -en "   \r"	
		sudo apt-get install ${array_deps_missing[@]}
	else
		echo "sudo apt-get install ${array_deps_missing[@]}"
	fi 
else
	fn_printoknl "Checking for missing dependencies"
fi
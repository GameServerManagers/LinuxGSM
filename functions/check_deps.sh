#!/bin/bash
# LGSM check_deps.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com

# Description: Checks that the require dependencies are installed for LGSM


fn_deps_detector(){
if [ -n "$(command -v dpkg-query)" ]; then
	dpkg-query -W -f='${Status}' ${deptocheck} | grep -q -P '^install ok installed$';
	depstatus=$?
elif [ -n "$(command -v rpm)" ]; then
	rpm -qa ${deptocheck} |grep -q -P ${deptocheck}
	depstatus=$?	
else
	echo "Unknown OS"
fi

}

cd "${executabledir}"
if [ "${executable}" == "./hlds_run" ]; then
	local depslist=( lib32gcc1 libstdc++6 libstdc++6:i386 )
	for deptocheck in "${depstocheck[@]}"
	do
		fn_deps_detector
	done
	# gold source lib32gcc1 libstdc++6 libstdc++6:i386 
elif [ "${executable}" ==  "./srcds_run" ]||[ "${executable}" ==  "./dabds.sh" ]||[ "${executable}" ==  "./srcds_run.sh" ]; then
	local depslist=( lib32gcc1 libstdc++6 libstdc++6:i386 )
	for deptocheck in "${depstocheck[@]}"
	do
		fn_deps_detector
	done
	# source lib32gcc1 libstdc++6 libstdc++6:i386 
elif [ "${executable}" ==  "./server_linux32" ]; then
	# lib32gcc1 libstdc++6 libstdc++6:i386 speex:i386 libtbb2
elif [ "${executable}" ==  "./runSam3_DedicatedServer.sh" ]; then
	# spark lib32gcc1 libstdc++6 libstdc++6:i386 
elif [ "${executable}" ==  "./7DaysToDie.sh" ]; then
	# lib32gcc1 libstdc++6 libstdc++6:i386 telnet expect
elif [ "${executable}" ==  "./ucc-bin" ]; then
        
	if [ -f "${executabledir}/ucc-bin-real" ]; then
		executable=ucc-bin-real
	elif [ -f "${executabledir}/ut2004-bin" ]; then
		executable=ut2004-bin
	else
		executable=ut-bin
	fi

elif [ "${executable}" ==  "./ts3server_startscript.sh" ]; then
	executable=ts3server_linux_amd64	
fi
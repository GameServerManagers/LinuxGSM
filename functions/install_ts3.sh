#!/bin/bash
# LGSM install_ts3.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

info_distro.sh
# Gets the teamspeak server architecture
if [ "${arch}" == "x86_64" ]; then
	ts3arch="amd64"
elif [ "${arch}" == "i386" ]||[ "${arch}" == "i686" ]; then
	ts3arch="x86"
else
	fn_printfailure "${arch} is an unsupported architecture"
	exit 1
fi

# Grabs all version numbers but not in correct order
wget "http://dl.4players.de/ts/releases/?C=M;O=D" -q -O -| grep -i dir | egrep -o '<a href=\".*\/\">.*\/<\/a>' | egrep -o '[0-9\.?]+'|uniq > .ts3_version_numbers_unsorted.tmp

# Sort version numbers
cat .ts3_version_numbers_unsorted.tmp | sort -r --version-sort -o .ts3_version_numbers_sorted.tmp

# Finds directory with most recent server version.
while read ts3_version_number; do
	wget --spider -q "http://dl.4players.de/ts/releases/${ts3_version_number}/teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2"
	if [ $? -eq 0 ]; then
		availablebuild="${ts3_version_number}"
		# Break while-loop, if the latest release could be found
		break
	fi
done < .ts3_version_numbers_sorted.tmp

# Tidy up
rm -f ".ts3_version_numbers_unsorted.tmp"
rm -f ".ts3_version_numbers_sorted.tmp"

# Checks availablebuild info is available
if [ -z "${availablebuild}" ]; then
	fn_printfail "Checking for update: teamspeak.com"
	fn_scriptlog "Checking for update: teamspeak.com"
	sleep 1
	fn_printfail "Checking for update: teamspeak.com: Not returning version info"
	fn_scriptlog "Failure! Checking for update: teamspeak.com: Not returning version info"
	sleep 2
	exit 1
fi

cd "${rootdir}"
echo -e "downloading teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2...\c"
wget -N /dev/null http://dl.4players.de/ts/releases/${ts3_version_number}/teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2 2>&1 | grep -F HTTP | cut -c45-| uniq
sleep 1
echo -e "extracting teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2...\c"
tar -xf "teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2" 2> ".${servicename}-tar-error.tmp"
local status=$?
if [ ${status} -eq 0 ]; then
	echo "OK"
else
	echo "FAIL - Exit status ${status}"
	sleep 1
	cat ".${servicename}-tar-error.tmp"
	rm ".${servicename}-tar-error.tmp"
	exit $?
fi
echo -e "copying to ${filesdir}...\c"
cp -R "${rootdir}/teamspeak3-server_linux_${ts3arch}/"* "${filesdir}" 2> ".${servicename}-cp-error.tmp"
local status=$?
if [ ${status} -eq 0 ]; then
	echo "OK"
else
	echo "FAIL - Exit status ${status}"
	sleep 1
	cat ".${servicename}-cp-error.tmp"
	rm ".${servicename}-cp-error.tmp"
	exit $?
fi
rm -f "teamspeak3-server_linux_${ts3arch}-${ts3_version_number}.tar.bz2"
rm -rf "${rootdir}/teamspeak3-server_linux_${ts3arch}"

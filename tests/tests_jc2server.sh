#!/bin/bash
# TravisCI Tests
# Server Management Script
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
version="101716"

#### Advanced Variables ####

# Github Branch Select
# Allows for the use of different function files
# from a different repo and/or branch.
githubuser="dgibbs64"
githubrepo="linuxgsm"
githubbranch="$TRAVIS_BRANCH"

##### Script #####

# Fetches core_dl for file downloads
fn_fetch_core_dl(){
github_file_url_dir="lgsm/functions"
github_file_url_name="${functionfile}"
filedir="${functionsdir}"
filename="${github_file_url_name}"
githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
# If the file is missing, then download
if [ ! -f "${filedir}/${filename}" ]; then
	if [ ! -d "${filedir}" ]; then
		mkdir -p "${filedir}"
	fi
	echo -e "    fetching ${filename}...\c"
	# Check curl exists and use available path
	curlpaths="$(command -v curl 2>/dev/null) $(which curl >/dev/null 2>&1) /usr/bin/curl /bin/curl /usr/sbin/curl /sbin/curl)"
	for curlcmd in ${curlpaths}
	do
		if [ -x "${curlcmd}" ]; then
			break
		fi
	done
	# If curl exists download file
	if [ "$(basename ${curlcmd})" == "curl" ]; then
		curlfetch=$(${curlcmd} -s --fail -o "${filedir}/${filename}" "${githuburl}" 2>&1)
		if [ $? -ne 0 ]; then
			echo -e "\e[0;31mFAIL\e[0m\n"
			echo "${curlfetch}"
			echo -e "${githuburl}\n"
			exit 1
		else
			echo -e "\e[0;32mOK\e[0m"
		fi
	else
		echo -e "\e[0;31mFAIL\e[0m\n"
		echo "Curl is not installed!"
		echo -e ""
		exit 1
	fi
	chmod +x "${filedir}/${filename}"
fi
source "${filedir}/${filename}"
}

core_dl.sh(){
# Functions are defined in core_functions.sh.
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_functions.sh(){
# Functions are defined in core_functions.sh.
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_dl.sh
core_functions.sh



# End of every test will expect the result to either pass or fail
# If the script does not do as intended the whole test will fail
# if excpecting a pass
fn_test_result_pass(){
	if [ $? != 0 ]; then
		fn_print_fail "Test Failed"
		exitcode=1
		core_exit.sh
	else
		fn_print_ok "Test Passed"
	fi
}

# if excpecting a fail
fn_test_result_fail(){
	if [ $? == 0 ]; then
		fn_print_fail "Test Failed"
		exitcode=1
		core_exit.sh
	else
		fn_print_ok "Test Passed"
	fi
}

echo "================================="
echo "TravisCI Tests"
echo "Linux Game Server Manager"
echo "by Daniel Gibbs"
echo "https://gameservermanagers.com"
echo "================================="
echo ""
echo "================================="
echo "Server Tests"
echo "Using: ${gamename}"
echo "Testing Branch: $TRAVIS_BRANCH"
echo "================================="
echo ""

echo "0.0 - Preparing Enviroment"
echo "================================="
echo "Description:"
echo "Preparing Enviroment to run tests"

echo "Downloading jc2server"
wget https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/JustCause2/jc2server
chmod +x jc2server
echo "Create log dir"
mkdir -pv log/script/
echo "Enable dev-debug"
./jc2server dev-debug

echo "1.0 - start - no files"
echo "================================="
echo "Description:"
echo "test script reaction to missing server files."
echo ""
./jc2server start
fn_test_result_fail

echo ""
echo "1.1 - getopt"
echo "================================="
echo "Description:"
echo "displaying options messages."
echo ""
./jc2server
fn_test_result_pass

echo ""
echo "1.2 - getopt with incorrect args"
echo "================================="
echo "Description:"
echo "displaying options messages."
echo ""
./jc2server
fn_test_result_fail

echo "2.0 - install"
echo "================================="
echo "Description:"
echo "install Just Cause 2 server."
./jc2server auto-install
fn_test_result_pass
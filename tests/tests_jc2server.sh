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

# End of every test will expect the result to either pass or fail
# If the script does not do as intended the whole test will fail
# if excpecting a pass
fn_test_result_pass(){
	if [ $? != 0 ]; then
		fn_print_fail "Test Failure"
		exitcode=1
		core_exit.sh
	else
		fn_print_ok "Test Pass"
	fi
}

# if excpecting a fail
fn_test_result_fail(){
	if [ $? == 0 ]; then
		fn_print_fail "Test Failure"
		exitcode=1
		core_exit.sh
	else
		fn_print_ok "Test Pass"
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
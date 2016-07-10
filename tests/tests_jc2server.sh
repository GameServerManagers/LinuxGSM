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


wget https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/JustCause2/jc2server

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
chmod +x
echo "Enable dev-debug"
./jc2server dev-debug
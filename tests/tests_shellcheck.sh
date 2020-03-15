#!/bin/bash
# Project: Game Server Managers - LinuxGSM
# Author: Daniel Gibbs
# License: MIT License, Copyright (c) 2019 Daniel Gibbs
# Purpose: Travis CI Tests: Shellcheck | Linux Game Server Management Script
# Contributors: https://github.com/GameServerManagers/LinuxGSM/graphs/contributors
# Documentation: https://docs.linuxgsm.com/
# Website: https://linuxgsm.com

echo -e "================================="
echo -e "Travis CI Tests"
echo -e "Linux Game Server Manager"
echo -e "by Daniel Gibbs"
echo -e "Contributors: http://goo.gl/qLmitD"
echo -e "https://linuxgsm.com"
echo -e "================================="
echo -e ""
echo -e "================================="
echo -e "Bash Analysis Tests"
echo -e "Using: Shellcheck"
echo -e "Testing Branch: $TRAVIS_BRANCH"
echo -e "================================="
echo -e ""
scissues=$(find . -type f  \( -name "*.sh" -o -name "*.cfg" \) -not -path "./shunit2-2.1.6/*" -exec shellcheck --shell=bash --exclude=SC2154,SC2034 {} \; | grep -F "^--" | wc -l)
echo -e "Found issues: ${scissues}"
echo -e "================================="
find . -type f  \( -name "*.sh" -o -name "*.cfg" \) -not -path "./shunit2-2.1.6/*" -exec shellcheck --shell=bash --exclude=SC2154,SC2034 {} \;
echo -e ""
echo -e "================================="
echo -e "Bash Analysis Tests - Complete!"
echo -e "Using: Shellcheck"
echo -e "================================="

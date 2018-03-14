#!/bin/bash
# Project: Game Server Managers - LinuxGSM
# Author: Daniel Gibbs
# License: MIT License, Copyright (c) 2017 Daniel Gibbs
# Purpose: TravisCI Tests: Shellcheck | Linux Game Server Management Script
# Contributors: https://github.com/GameServerManagers/LinuxGSM/graphs/contributors
# Documentation: https://github.com/GameServerManagers/LinuxGSM/wiki
# Website: https://gameservermanagers.com

echo "START Shellcheck"
echo "================================="
find . -type f -name "*.sh" -not -path "./shunit2-2.1.6/*" -exec shellcheck --shell=bash --exclude=SC2154,SC2034 {} \;
find . -type f -name "*.cfg" -not -path "./shunit2-2.1.6/*" -exec shellcheck --shell=bash --exclude=SC2154,SC2034 {} \;
echo "================================="
echo "END Shellcheck"
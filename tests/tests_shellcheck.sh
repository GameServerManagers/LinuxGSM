#!/bin/bash
# Project: Game Server Managers - LinuxGSM
# Author: Daniel Gibbs
# License: MIT License, Copyright (c) 2017 Daniel Gibbs
# Purpose: TravisCI Tests: Shellcheck | Linux Game Server Management Script
# Contributors: https://github.com/GameServerManagers/LinuxGSM/graphs/contributors
# Documentation: https://github.com/GameServerManagers/LinuxGSM/wiki
# Website: https://gameservermanagers.com

find . -type f -name "shunit2-2.1.6" -prune -name "*.sh" -exec shellcheck --shell=bash --exclude=SC2154,SC2034 {} \;
find . -type f -name "shunit2-2.1.6" -prune -name "*.cfg" -exec shellcheck --shell=bash --exclude=SC2154,SC2034 {} \;

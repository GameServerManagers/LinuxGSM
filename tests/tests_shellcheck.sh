#!/bin/bash
# Project: Game Server Managers - LinuxGSM
# Author: Daniel Gibbs
# License: MIT License, Copyright (c) 2017 Daniel Gibbs
# Purpose: TravisCI Tests: Teamspeak 3 | Linux Game Server Management Script
# Contributors: https://github.com/GameServerManagers/LinuxGSM/graphs/contributors
# Documentation: https://github.com/GameServerManagers/LinuxGSM/wiki
# Website: https://gameservermanagers.com

command -v shellcheck
shellcheck --shell=bash --exclude=SC2154,SC2034 GameServerManagers/LinuxGSM/lgsm/functions/*
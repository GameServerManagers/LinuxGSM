#!/bin/bash
# LGSM install_factorio_save.sh function
# Author: Kristian Polso
# Website: https://gameservermanagers.com
# Description: Creates the initial save file for Factorio

local commandname="INSTALL"
local commandaction="Install"

echo ""
echo "Creating initial Factorio savefile"
echo "================================="
sleep 1
${filesdir}/bin/x64/factorio --create ${filesdir}/save1
cp ${filesdir}/data/server-settings.example.json ${filesdir}/data/server-settings.json

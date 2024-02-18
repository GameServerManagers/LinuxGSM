#!/bin/bash
# LinuxGSM fix_csgo.sh module
# Author: https://github.com/pcace
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Counter-Strike: Global Offensive.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: metamod installation (if installed) on cs2 updates
GAMEINFO="${serverfiles}/game/csgo/gameinfo.gi"
METAMOD_DIR="${serverfiles}/game/csgo/addons/metamod"

if [ -d "$METAMOD_DIR" ]; then

    # Remove Windows line endings (\r) from gameinfo.gi
    sed -i 's/\r$//' "$GAMEINFO"

    # Check if the line "Game    csgo/addons/metamod" exists in the file
    if ! grep -q "Game    csgo/addons/metamod" "$GAMEINFO"; then

        # Open gameinfo.gi in the game/csgo directory
        sed -i 's/#.*\n//g' "$GAMEINFO"

        # Add Game csgo/addons/metamod to the SearchPaths section
        sed -i '/Game_LowViolence/{
            a             Game    csgo/addons/metamod
        }' "$GAMEINFO"

    fi
fi

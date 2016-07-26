#!/bin/bash
# LGSM check_system_requirements.sh
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Checks RAM requirement

mbphysmem=$(free -m | awk '/Mem:/ {print $2}')

# RAM requirement in MegaBytes for each game or engine
if [ "${gamename}" == "Rust" ]; then
  ramrequirement="4000"
fi

# If the game or engine has a minimum RAM Requirement, compare it to system's available RAM
if [ -n "${ramrequirement}" ]; then
  if [ "${mbphysmem}" -lt "${ramrequirement}" ]; then
    # Warn the user
    fn_print_warn "Insufficient physical RAM: ${mbphysmem}MB available for ${ramrequirement}MB required."
    sleep 2
    echo ""
    echo "You may encounter issues such as server lagging or shutting down unexpectedly."
    sleep 0.5
    fn_script_log_warn "Insufficient physical RAM: ${mbphysmem}MB available for ${ramrequirement}MB required."
  fi
fi  

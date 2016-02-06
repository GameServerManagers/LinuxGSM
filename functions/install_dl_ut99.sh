#!/bin/bash
# LGSM install_dl_ut99.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="050216"

echo ""
echo "Downloading Server Files"
echo "================================="
sleep 1
fn_dl "ut-server-451-complete.tar.bz2" "${filesdir}" "http://gameservermanagers.com/files/ut99/ut-server-451-complete.tar.bz2" "42a8c9806e4fce10a56830caca83ce63"

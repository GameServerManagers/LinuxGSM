#!/bin/bash
# LGSM install_dl_ut99.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="050216"

echo ""
echo "Downloading Server Files"
echo "================================="
sleep 1
fn_fetch_file "http://gameservermanagers.com/files/ut-server-451-complete.tar.bz2" "${lgsmdir}/tmp" "ut-server-451-complete.tar.bz2" "norun" "noforce" "42a8c9806e4fce10a56830caca83ce63"
fn_dl_extract "${lgsmdir}/tmp" "ut-server-451-complete.tar.bz2" "${filesdir}"
#!/bin/bash
# LGSM fix_arma3.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="301215"

# Fixes: server not always creating steam_appid.txt file.
if [ ! -d "${rootdir}/.local/share/Arma\ 3" ]; then
	fixname="20150 Segmentation fault (core dumped)"
	fn_fix_msg_start
	mkdir -p "${rootdir}/.local/share/Arma\ 3"
	fn_fix_msg_end
fi
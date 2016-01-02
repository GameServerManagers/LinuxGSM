#!/bin/bash
# LGSM fix_arma3.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="301215"

# Fixes line 63: 20150 Segmentation fault (core dumped) #488

fn_msg_start(){
	fn_printdots "Applying ${fixname} fix: ${gamename}"
	sleep 1
	fn_printinfo "Applying ${fixname} fix: ${gamename}"
	fn_scriptlog "Applying ${fixname} fix: ${gamename}"
	sleep 1
}

fn_msg_end(){
	if [ $? -ne 0 ]; then
		fn_printfailnl "Applying ${fixname} fix: ${gamename}"
		fn_scriptlog "Failure! Applying ${fixname} fix: ${gamename}"
	else
		fn_printoknl "Applying ${fixname} fix: ${gamename}"
		fn_scriptlog "Complete! Applying ${fixname} fix: ${gamename}"
	fi	
}

# Fixes: server not always creating steam_appid.txt file.
if [ ! -d "${rootdir}/.local/share/Arma\ 3" ]; then
	local fixname="20150 Segmentation fault (core dumped)"
	fn_msg_start
	mkdir -p "${rootdir}/.local/share/Arma\ 3"
	fn_msg_end
fi
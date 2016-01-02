#!/bin/bash
# LGSM fix_dst.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="020116"

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

# Fixes: ./dontstarve_dedicated_server_nullrenderer: ./lib32/libcurl-gnutls.so.4: no version information available (required by ./dontstarve_dedicated_server_nullrenderer)
# Issue only occures on CentOS as libcurl-gnutls.so.4 is called libcurl.so.4 on CentOS.
if [ -f "/etc/redhat-release" ] && [ ! -f "${filesdir}/bin/lib32/libcurl-gnutls.so.4" ]; then
	local fixname="libcurl-gnutls.so.4 missing"
	fn_msg_start
	ln -s "/usr/lib/libcurl.so.4" "${filesdir}/bin/lib32/libcurl-gnutls.so.4"
	fn_msg_end
fi
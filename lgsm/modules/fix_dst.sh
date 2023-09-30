#!/bin/bash
# LinuxGSM fix_dst.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Don't Starve Together.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: ./dontstarve_dedicated_server_nullrenderer: ./lib32/libcurl-gnutls.so.4: no version information available (required by ./dontstarve_dedicated_server_nullrenderer).
# Issue only occures on CentOS as libcurl-gnutls.so.4 is called libcurl.so.4 on CentOS.
if [ -f "/etc/redhat-release" ] && [ ! -f "${serverfiles}/bin/lib32/libcurl-gnutls.so.4" ]; then
	fixname="libcurl-gnutls.so.4"
	fn_fix_msg_start
	ln -s "/usr/lib/libcurl.so.4" "${serverfiles}/bin/lib32/libcurl-gnutls.so.4"
	fn_fix_msg_end
fi

# Keeps shard name in server.ini the same as in the LinuxGSM config.
if [ -f "${servercfgfullpath}" ]; then
	if [ "$(grep -Ec '^name[[:space:]]*=' "${servercfgfullpath}")" -eq 1 ]; then
		if [ "$(grep -E '^name[[:space:]]*=' "${servercfgfullpath}" | cut -d '=' -f2 | tr -d '"' | tr -d ' ')" != "${shard}" ]; then
			fixname="update server.ini shard name"
			fn_fix_msg_start
			sed -i -e "s/name[[:space:]]*=.*/name = \"${shard}\"/g" "${servercfgfullpath}"
			fn_fix_msg_end
		fi
	fi
fi

#!/bin/bash
# LinuxGSM install_dst_token.sh function
# Author: Daniel Gibbs & Marvin Lehmann (marvinl97)
# Website: https://linuxgsm.com
# Description: Configures Don't Starve Together cluster with given token.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo ""
echo "Enter ${gamename} Cluster Token"
echo "================================="
sleep 0.5
echo "A cluster token is required to run this server!"
echo "Follow the instructions in this link to obtain this key:"
echo "https://linuxgsm.com/dst-auth-token"
echo ""
if [ -z "${autoinstall}" ]; then
	overwritetoken="true"
	if [ -s "${clustercfgdir}/cluster_token.txt" ]; then
		echo "The cluster token is already set. Do you want to overwrite it?"
		fn_script_log_info "Don't Starve Together cluster token is already set"
		if fn_prompt_yn "Continue?" N; then
			overwritetoken="true"
		else
			overwritetoken="false"
		fi
	fi
	if [ "${overwritetoken}" == "true" ]; then
		echo "Once you have the cluster token, enter it below"
		echo -n "Cluster Token: "
		read -r token
		mkdir -pv "${clustercfgdir}"
		echo "${token}" > "${clustercfgdir}/cluster_token.txt"
		if [ -f "${clustercfgdir}/cluster_token.txt" ]; then
			echo "Don't Starve Together cluster token created"
			fn_script_log_info "Don't Starve Together cluster token created"
		fi
		unset overwritetoken
	fi
else
	echo "You can add your cluster token using the following command"
	echo "./${selfname} cluster-token"
fi
echo ""

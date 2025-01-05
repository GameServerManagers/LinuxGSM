#!/bin/bash
# LinuxGSM install_dst_token.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Configures Don't Starve Together cluster with given token.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${bold}${lightyellow}Enter ${gamename} Cluster Token${default}"
fn_messages_separator
echo -e "A cluster token is required to run this server!"
echo -e "Follow the instructions in this link to obtain this key:"
echo -e "${italic}https://linuxgsm.com/dst-auth-token"
echo -e ""
if [ -z "${autoinstall}" ]; then
	overwritetoken="true"
	if [ -s "${clustercfgdir}/cluster_token.txt" ]; then
		echo -e "The cluster token is already set. Do you want to overwrite it?"
		fn_script_log_info "Don't Starve Together cluster token is already set"
		if fn_prompt_yn "Continue?" N; then
			overwritetoken="true"
		else
			overwritetoken="false"
		fi
	fi
	if [ "${overwritetoken}" == "true" ]; then
		echo -e "Once you have the cluster token, enter it below"
		echo -n "Cluster Token: "
		read -r token
		mkdir -pv "${clustercfgdir}"
		echo -e "${token}" > "${clustercfgdir}/cluster_token.txt"
		if [ -f "${clustercfgdir}/cluster_token.txt" ]; then
			echo -e "Don't Starve Together cluster token created"
			fn_script_log_info "Don't Starve Together cluster token created"
		fi
		unset overwritetoken
	fi
else
	echo -e "You can add your cluster token using the following command"
	echo -e "./${selfname} cluster-token"
fi
echo -e ""

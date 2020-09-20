#!/bin/bash
# LinuxGSM command_postdetails.sh function
# Author: CedarLUG
# Contributor: CedarLUG
# Website: https://linuxgsm.com
# Description: Strips sensitive information out of Details output

commandname="POST-DETAILS"
commandaction="Posting details"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

posttarget="https://termbin.com"

# source all of the functions defined in the details command.
info_messages.sh

fn_bad_postdetailslog() {
	fn_print_fail_nl "Unable to create temporary file ${postdetailslog}."
	core_exit.sh
}

# Remove any existing postdetails.log file.
if [ -f "${postdetailslog}" ]; then
	rm -f "${postdetailslog:?}"
fi

# Rather than a one-pass sed parser, default to using a temporary directory.
if [ "${exitbypass}" ]; then
	postdetailslog="${alertlog}"
else
	# Run checks and gathers details to display.
	check.sh
	info_config.sh
	info_parms.sh
	info_distro.sh
	info_messages.sh
	for queryip in "${queryips[@]}"
	do
		query_gamedig.sh
		if [ "${querystatus}" == "0" ]; then
			break
		fi
	done
	touch "${postdetailslog}" || fn_bad_postdetailslog
	{
		fn_info_message_distro
		fn_info_message_server_resource
		fn_info_message_gameserver_resource
		fn_info_message_gameserver
		fn_info_message_script
		fn_info_message_backup
		# Some game servers do not have parms.
		if [ "${shortname}" != "jc2" ]&&[ "${shortname}" != "jc3" ]&&[ "${shortname}" != "dst" ]&&[ "${shortname}" != "pz" ]&&[ "${engine}" != "renderware" ]; then
			fn_parms
			fn_info_message_commandlineparms
		fi
		fn_info_message_ports
		fn_info_message_select_engine
		fn_info_message_statusbottom
	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | tee -a "${postdetailslog}" > /dev/null 2>&1
fi

fn_print_dots "termbin.com"
link=$(cat "${postdetailslog}" | nc termbin.com 9999 | tr -d '\n\0')
fn_print_ok_nl "termbin.com for 30D"
fn_script_log_pass "termbin.com for 30D"
pdurl="${link}"

if [ ${firstcommandname} == "POST-DETAILS" ]; then
	echo -e ""
	echo -e "Please share the following url for support: "
	echo -e "${pdurl}"
fi
fn_script_log_info "${pdurl}"

if [ -z "${exitbypass}" ]; then
	core_exit.sh
fi
alerturl="${pdurl}"

#!/bin/bash
# LinuxGSM command_postdetails.sh function
# Author: CedarLUG
# Contributor: CedarLUG
# Website: https://linuxgsm.com
# Description: Strips sensitive information out of Details output

local modulename="POSTDETAILS"
local commandaction="Postdetails"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

# Set posttarget to the appropriately-defined post destination.

# The options for posttarget are:
# The default destination - hastebin
# posttarget="https://hastebin.com"
#
# Secondary destination - pastebin
# posttarget="http://pastebin.com
#
# Third option - leave on the filesystem
# posttarget=
#
# All of these options can be specified/overridden from the top-level
# invocation, as in:
#  rustserver@gamerig:~$ posttarget="http://pastebin.com" ./rustserver pd
# to post to pastebin, or
#  rustserver@gamerig:~$ posttarget= ./rustserver pd
# to leave the output on the filesystem.
posttarget=${posttarget="https://termbin.com"}

# For pastebin, you can set the expiration period.
# use 1 week as the default, other options are '24h' for a day, etc.
# This, too, may be overridden from the command line at the top-level.
postexpire="${postexpire="30D"}"

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
	query_gamedig.sh
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
	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee -a "${postdetailslog}" > /dev/null 2>&1
fi

if [ "${posttarget}" == "http://pastebin.com" ] ; then
	fn_print_dots "Posting details to pastbin.com for ${postexpire}"
	# grab the return from 'value' from an initial visit to pastebin.
	csrftoken=$(curl -s "${posttarget}" |
					sed -n 's/^.*input type="hidden" name="csrf_token_post" value="\(.*\)".*$/\1/p')
	#
	# Use the csrftoken to then post the content.
	#
	link=$(curl -s "${posttarget}/post.php" -D - -F "submit_hidden=submit_hidden" \
				-F "post_key=${csrftoken}" -F "paste_expire_date=${postexpire}" \
				-F "paste_name=${gamename} Debug Info" \
				-F "paste_format=8" -F "paste_private=0" \
				-F "paste_type=bash" -F "paste_code=<${postdetailslog}" |
				awk '/^location: / { print $2 }' | sed "s/\n//g")

	 # Output the resulting link.
	fn_print_ok_nl "Posting details to pastbin.com for ${postexpire}"
	pdurl="${posttarget}${link}"
	echo -e "  Please share the following url for support: ${pdurl}"
elif [ "${posttarget}" == "https://hastebin.com" ] ; then
	fn_print_dots "Posting details to hastebin.com"
	# hastebin is a bit simpler.  If successful, the returned result
	# should look like: {"something":"key"}, putting the reference that
	# we need in "key".  TODO - error handling. -CedarLUG
	link=$(curl -H "HTTP_X_REQUESTED_WITH:XMLHttpRequest" -s -d "$(<${postdetailslog})" "${posttarget}/documents" | cut -d\" -f4)
	fn_print_ok_nl "Posting details to hastebin.com for ${postexpire}"
	pdurl="${posttarget}/${link}"
	echo -e "Please share the following url for support: ${pdurl}"
elif [ "${posttarget}" == "https://termbin.com" ] ; then
	fn_print_dots "Posting details to termbin.com"
	link=$(cat "${postdetailslog}" | nc termbin.com 9999 | tr -d '\n\0')
	fn_print_ok_nl "Posting details to termbin.com"
	pdurl="${link}"
	echo -e "Please share the following url for support: "
	echo -e "${pdurl}"
else
	 fn_print_warn_nl "Review output in: ${postdetailslog}"
	 core_exit.sh
fi

if [ -z "${exitbypass}" ]; then
	core_exit.sh
else
	alerturl="${pdurl}"
fi

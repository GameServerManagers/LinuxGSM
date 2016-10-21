#!/bin/bash
# LGSM command_postdetails.sh function
# Author: CedarLUG
# Contributor: CedarLUG
# Website: https://gameservermanagers.com
# Description: Strips sensitive information out of Details output

local commandname="postdetails"
local commandaction="Postdetails"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

# postdetails variable affects the output of command_details.sh.  Setting
# it here silences the output from sourcing command_details.sh.
postdetails=yes

# Set posttarget to the appropriately-defined post destination.

# The options for posttarget are:
# The default destination - hastebin
# posttarget="http://hastebin.com"
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
posttarget=${posttarget="http://hastebin.com"}

# For pastebin, you can set the expiration period.
# use 1 week as the default, other options are '24h' for a day, etc.
# This, too, may be overridden from the command line at the top-level
postexpire="${postexpire="1W"}"

# This file sources the command_details.sh file to leverage all
# of the already-defined functions.  To keep the command_details.sh
# from actually producing output, the main executable statements have
# been wrapped in the equivalent of an ifdef clause, that looks
# for the variable "postdetails" to be defined. -CedarLUG

# source all of the functions defined in the details command
command_details.sh

# redefine as command_details.sh changes them
local commandname="postdetails"
local commandaction="Postdetails"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_bad_tmpfile() {
	echo "There was a problem creating a temporary file ${tmpfile}."
	core_exit.sh
}

# Rather than a one-pass sed parser, default to using a temporary directory
tmpfile="${tmpdir}/postdetails-$(date +"%Y-%d-%m_%H-%M-%S").tmp"

touch "${tmpfile}" || fn_bad_tmpfile

# fn_display_details is found in the command_details.sh file (which
# was sourced above).  The output is parsed for passwords and other
# confidential information. -CedarLUG

# The numerous sed lines could certainly be condensed quite a bit,
# but they are separated out to provide examples for how to add
# additional criteria in a straight-forward manner.
# (This was originally a sed one-liner.) -CedarLUG

fn_display_details | sed -e 's/password="[^"]*/password="--stripped--/' |
									sed -e 's/password "[^"]*/password "--stripped--/' |
									sed -e 's/password: .*/password: --stripped--/' |
									sed -e 's/gslt="[^"]*/gslt="--stripped--/' |
									sed -e 's/gslt "[^"]*/gslt "--stripped--/' |
									sed -e 's/pushbullettoken="[^"]*/pushbullettoken="--stripped--/' |
									sed -e 's/pushbullettoken "[^"]*/pushbullettoken "--stripped--/' |
									sed -e 's/authkey="[^"]*/authkey="--stripped--/' |
									sed -e 's/authkey "[^"]*/authkey "--stripped--/' |
									sed -e 's/authkey [A-Za-z0-9]\+/authkey --stripped--/' |
									sed -e 's/rcts_strAdminPassword="[^"]*/rcts_strAdminPassword="--stripped--/' |
									sed -e 's/rcts_strAdminPassword "[^"]*/rcts_strAdminPassword "--stripped--/' |
									sed -e 's/sv_setsteamaccount [A-Za-z0-9]\+/sv_setsteamaccount --stripped--/' |
									sed -e 's/sv_password="[^"]*/sv_password="--stripped--/' |
									sed -e 's/sv_password "[^"]*/sv_password "--stripped--/' |
									sed -e 's/zmq_stats_password="[^"]*/zmq_stats_password="--stripped--/' |
									sed -e 's/zmq_stats_password "[^"]*/zmq_stats_password "--stripped--/' |
									sed -e 's/zmq_rcon_password="[^"]*/zmq_rcon_password="--stripped--/' |
									sed -e 's/zmq_rcon_password "[^"]*/zmq_rcon_password "--stripped--/' |
									sed -e 's/pass="[^"]*/pass="--stripped--/' |
									sed -e 's/pass "[^"]*/pass "--stripped--/' |
									sed -e 's/rconServerPassword="[^"]*/rconServerPassword="--stripped--/' |
									sed -e 's/rconServerPassword "[^"]*/rconServerPassword "--stripped--/' > "${tmpfile}"

# strip off all console escape codes (colorization)
sed -i -r "s/[\x1B,\x0B]\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" "${tmpfile}"

# If the gameserver uses anonymous steam credentials, leave them displayed
# in the output.  Otherwise, strip these out as well.
if ! grep -q "^steampass[= ]\"\"" "${tmpfile}" ; then
	sed -i -e 's/steampass[= ]"[^"]*/steampass "--stripped--/' "${tmpfile}"
fi
if ! grep -q "^steamuser[= ]\"anonymous\"" "${tmpfile}" ; then
	sed -i -e 's/steamuser[= ]"[^"]*/steamuser "--stripped--/' "${tmpfile}"
fi


if [ "${posttarget}" == "http://pastebin.com" ] ; then
	fn_print_dots "Posting details to pastbin.com for ${postexpire}"
	sleep 1
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
				-F "paste_type=bash" -F "paste_code=<${tmpfile}" |
				awk '/^location: / { print $2 }' | sed "s/\n//g")

	 # Output the resulting link.
	fn_print_ok_nl "Posting details to pastbin.com for ${postexpire}"
	echo "  * url: ${posttarget}${link}"
elif [ "${posttarget}" == "http://hastebin.com" ] ; then
	fn_print_dots "Posting details to hastebin.com for ${postexpire}"
	sleep 1
	# hastebin is a bit simpler.  If successful, the returned result
	# should look like: {"something":"key"}, putting the reference that
	# we need in "key".  TODO - error handling. -CedarLUG
	link=$(curl -s -d "$(<${tmpfile})" "${posttarget}/documents" | cut -d\" -f4)
	fn_print_ok_nl "Posting details to hastebin.com for ${postexpire}"
	echo "  * url: ${posttarget}/${link}"
else
	 fn_print_warn_nl Review the output in "${tmpfile}"
	 core_exit.sh
fi

# cleanup
rm "${tmpfile}" || /bin/true
core_exit.sh

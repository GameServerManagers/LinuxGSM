#!/bin/bash
# LinuxGSM alert_discord.sh function
# Author: Daniel Gibbs
# Contributor: faflfama
# Website: https://gameservermanagers.com
# Description: Sends Discord alert including the server status.

if [ "$1" == "" ]; then  echo "missing message"; exit; fi
prefix='{"content":"'
postfix='","file":"content","embed":"content"}'
echo "$prefix $1 $postfix" >f
curl -v -X POST --data @f "${discordwebhook}"

#if [ "${discordsend}" == "invalid_access_token" ]; then
#	fn_print_fail_nl "Sending Discord alert: invalid_access_token"
#	fn_script_log_fatal "Sending Discord alert: invalid_access_token"
#else
#	fn_print_ok_nl "Sending Discord alert"
#	fn_script_log_pass "Sent Discord alert"
#fi
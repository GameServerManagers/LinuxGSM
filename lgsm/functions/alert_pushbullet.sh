#!/bin/bash
# LGSM alert_pushbullet.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="140516"

# Description: alerts using pushbullet.

local modulename="Alert"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

curl -u """${pushbullettoken}"":" -d type="note" -d body="${alertbody}" -d title="${alertsubject}" 'https://api.pushbullet.com/v2/pushes' >/dev/null 2>&1
fn_print_ok_nl "Sent Pushbullet alert"
fn_scriptlog "Sent Pushbullet alert"

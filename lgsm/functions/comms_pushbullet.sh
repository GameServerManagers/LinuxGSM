#!/bin/bash
# LGSM comms_pushbullet.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="140516"

# Description: Notifications using pushbullet.

local modulename="Comms"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

curl -u """${pushbullettoken}"":" -d type="note" -d body="${commsbody}" -d title="${commssubject}" 'https://api.pushbullet.com/v2/pushes' >/dev/null 2>&1
fn_print_ok_nl "Sent Pushbullet notification"
fn_scriptlog "Sent Pushbullet notification"

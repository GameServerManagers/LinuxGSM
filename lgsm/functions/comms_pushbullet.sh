#!/bin/bash
# LGSM comms_pushbullet.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="140516"

# Description: Notifications using pushbullet.

curl -u """${pushbullettoken}"":" -d type="note" -d body="${commsbody}" -d title="${commstitle}" 'https://api.pushbullet.com/v2/pushes' >/dev/null 2>&1
fn_print_ok_nl "Sent Pushbullet notification"
fn_scriptlog "Sent Pushbullet notification"

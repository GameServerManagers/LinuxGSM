#!/bin/bash
# LGSM comms_pushbullet.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="140516"

# Description: Notifications using pushbullet.

fn_comms_pushbullet() {
    PUSHBULLET_TOKEN="userTokenHere";
    curl -u """$pushbullettoken"":" -d type="note" -d body="${commsbody}" -d title="${commstitle}" 'https://api.pushbullet.com/v2/pushes' >/dev/null 2>&1
    echo "Message send to pushbullet.";
}

pushbulletnotification="on"
pushbullettoken=""
commsbody="${servicename} process not running"
fn_comms_pushbullet
#!/bin/bash
# LinuxGSM alert_ifttt.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Sends IFTTT alert.

local commandname="ALERT"
local commandaction="Alert"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

json=$(cat <<EOF
{
	"value1": "${servicename}",
	"value2": "${alertemoji} ${alertsubject} ${alertemoji}",
	"value3": "Message\n${alertbody}\n\nGame\n${gamename}\n\nServer name\n${servername}\n\nHostname\n${HOSTNAME}\n\nServer IP\n${ip}:${port}\n\nMore info\n${alerturl}"
}
EOF
)

curl -sSL -H "Content-Type: application/json" -X POST -d """${json}""" "https://maker.ifttt.com/trigger/linuxgsm_alert/with/key/${ifttttoken}"
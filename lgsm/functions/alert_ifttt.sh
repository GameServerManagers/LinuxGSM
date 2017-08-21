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
	"secret": "${pushjettoken}",
	"level": "5",
	"message": "all",
	"link": "https://gameservermanagers.com"
}
EOF
)

curl -sSL -H "Content-Type: application/json" -X POST -d """${json}""" "https://maker.ifttt.com/trigger/{event}/with/key/${ifttttoken}"
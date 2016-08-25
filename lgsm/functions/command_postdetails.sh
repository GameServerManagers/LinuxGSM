#!/bin/bash
# LGSM command_details.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Displays server information.

local commandname="POSTDETAILS"
local commandaction="Postdetails"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

postdetails=yes

# source all of the functions defined in the details command
. ${functionsdir}/command_details.sh

#INPUT="$(</dev/stdin)"

fn_display_details | sed -e 's/password="[^"]*/password="--stripped--/' |
                sed -e 's/password "[^"]*/password "--stripped--/' |
                sed -e 's/password: .*/password: --stripped--/' |
                sed -e 's/gslt="[^"]*/gslt="--stripped--/' |
                sed -e 's/gslt "[^"]*/gslt "--stripped--/' |
                sed -e 's/steamuser="[^"]*/steamuser="--stripped--/' |
                sed -e 's/steamuser "[^"]*/steamuser "--stripped--/' |
                sed -e 's/steampass="[^"]*/steampass="--stripped--/' |
                sed -e 's/steampass "[^"]*/steampass "--stripped--/' |
                sed -e 's/pushbullettoken="[^"]*/pushbullettoken="--stripped--/' |
                sed -e 's/pushbullettoken "[^"]*/pushbullettoken "--stripped--/' |
                sed -e 's/authkey="[^"]*/authkey="--stripped--/' |
                sed -e 's/authkey "[^"]*/authkey "--stripped--/' |
                sed -e 's/rcts_strAdminPassword="[^"]*/rcts_strAdminPassword="--stripped--/' |
                sed -e 's/rcts_strAdminPassword "[^"]*/rcts_strAdminPassword "--stripped--/' |
                sed -e 's/sv_password="[^"]*/sv_password="--stripped--/' |
                sed -e 's/sv_password "[^"]*/sv_password "--stripped--/' |
                sed -e 's/zmq_stats_password="[^"]*/zmq_stats_password="--stripped--/' |
                sed -e 's/zmq_stats_password "[^"]*/zmq_stats_password "--stripped--/' |
                sed -e 's/zmq_rcon_password="[^"]*/zmq_rcon_password="--stripped--/' |
                sed -e 's/zmq_rcon_password "[^"]*/zmq_rcon_password "--stripped--/' |
                sed -e 's/pass="[^"]*/pass="--stripped--/' |
                sed -e 's/pass "[^"]*/pass "--stripped--/' |
                sed -e 's/rconServerPassword="[^"]*/rconServerPassword="--stripped--/' |
                sed -e 's/rconServerPassword "[^"]*/rconServerPassword "--stripped--/'
		
#querystring="paste_private=0&paste_name=${NAME}&paste_code=${INPUT}"
#curl -d "${querystring}" http://pastebin.com/api_public.php
core_exit.sh

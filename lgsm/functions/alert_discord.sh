#!/bin/bash
# LinuxGSM alert_discord.sh function
# Author: Daniel Gibbs
# Contributor: faflfama
# Website: https://gameservermanagers.com
# Description: Sends Discord alert including the server status.

curl -X POST --data '{ "embeds": [{"title": "${pbalertsubject}", "url": "https://example.com", "description": "${pbalertbody}", "type": "link", "thumbnail": {"url": "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/images/logo/lgsm-square-184-dark.png"}}] }' -H "Content-Type: application/json" "${discordwebhook}"
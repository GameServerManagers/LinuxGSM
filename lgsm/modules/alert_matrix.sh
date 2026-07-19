#!/bin/bash
# LinuxGSM alert_matrix.sh module
# Author: Daniel Gibbs (Original Structure)
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Matrix alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

matrixbase="${matrixhomeserver}"
if [[ "${matrixbase}" != http://* ]] && [[ "${matrixbase}" != https://* ]]; then
	matrixbase="https://${matrixbase}"
fi
matrixbase="${matrixbase%/}"

# matrixroom must be the internal room ID (e.g. !abc123:matrix.org), not the room alias (#room:matrix.org).
matrixroomencoded="$(jq -rn --arg room "${matrixroom}" '$room|@uri')"
matrixtxnid="$(date +%s%N)"
matrixurl="${matrixbase}/_matrix/client/v3/rooms/${matrixroomencoded}/send/m.room.message/${matrixtxnid}"

message="${alerttitle}

Server Name
${servername}

Information
${alertmessage}

Game
${gamename}

Server IP
${alertip}:${port}

Server Time
$(date)"

if [ -n "${querytype}" ]; then
	message+="

Is my Game Server Online?
https://ismygameserver.online/${imgsoquerytype}/${alertip}:${queryport}"
fi

if [ -n "${alerturl}" ]; then
	message+="

More info
${alerturl}"
fi

json="$(jq -cn --arg body "${message}" '{msgtype: "m.notice", body: $body}')"

fn_print_dots "Sending Matrix alert"

matrixsend=$(curl --connect-timeout 10 -sSL -X PUT \
	-H "Authorization: Bearer ${matrixtoken}" \
	-H "Content-Type: application/json" \
	-d "${json}" \
	"${matrixurl}")
exitcode=$?

matrixeventid="$(echo "${matrixsend}" | jq -r '.event_id // empty' 2> /dev/null)"
if [ "${exitcode}" -eq 0 ] && [ -n "${matrixeventid}" ]; then
	fn_print_ok_nl "Sending Matrix alert"
	fn_script_log_pass "Sending Matrix alert"
else
	fn_print_fail_nl "Sending Matrix alert: ${matrixsend}"
	fn_script_log_fail "Sending Matrix alert: ${matrixsend}"
fi

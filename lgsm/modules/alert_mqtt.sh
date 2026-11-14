#!/bin/bash
# LinuxGSM alert_mqtt.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends MQTT alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -z "$(command -v mosquitto_pub 2> /dev/null)" ]; then
	fn_print_fail_nl "mosquitto_pub is not installed. MQTT alerts are not available"
	fn_script_log_fail "mosquitto_pub is not installed. MQTT alerts are not available"
	return
fi

json=$(
	jq -cn \
		--arg title "${alerttitle}" \
		--arg message "${alertmessage}" \
		--arg server "${servername}" \
		--arg game "${gamename}" \
		--arg host "${HOSTNAME}" \
		--arg ip "${alertip}:${port}" \
		--arg url "${alerturl}" \
		--arg time "$(date)" \
		'{title: $title, message: $message, server: $server, game: $game, hostname: $host, ip: $ip, url: $url, time: $time}'
)

cmd=(mosquitto_pub -h "${mqtthost}" -p "${mqttport}" -t "${mqtttopic}" -s)
if [ -n "${mqttuser}" ]; then
	cmd+=(-u "${mqttuser}")
fi
if [ -n "${mqttpassword}" ]; then
	cmd+=(-P "${mqttpassword}")
fi
if [ "${mqtttls}" == "on" ]; then
	cmd+=(--capath /etc/ssl/certs)
fi

fn_print_dots "Sending MQTT alert"
mqttsend=$(echo -n "${json}" | timeout 15 "${cmd[@]}" 2>&1)
exitcode=$?

if [ "${exitcode}" -eq 0 ]; then
	fn_print_ok_nl "Sending MQTT alert"
	fn_script_log_pass "Sending MQTT alert"
else
	fn_print_fail_nl "Sending MQTT alert: ${mqttsend}"
	fn_script_log_fail "Sending MQTT alert: ${mqttsend}"
fi

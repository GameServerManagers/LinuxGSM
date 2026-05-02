#!/bin/bash
# LinuxGSM info_stats.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Collect optional Stats sent to LinuxGSM project.
# Uses Google analytics.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

info_distro.sh

# remove uuid that was used in v20.2.0 and below
if [ -f "${datadir}/uuid.txt" ]; then
	rm -f "${datadir:?}/uuid.txt"
fi

# generate uuid's
# this consists of a standard uuid and a docker style name
# to allow human readable uuid's.
# e.g angry_proskuriakova_38a9ef76-4ae3-46a6-a895-7af474831eba

if [ ! -f "${datadir}/uuid-${selfname}.txt" ] || [ ! -f "${datadir}/uuid-install.txt" ]; then
	# download dictionary words
	if [ ! -f "${datadir}/name-left.csv" ]; then
		fn_fetch_file_github "lgsm/data" "name-left.csv" "${datadir}" "nochmodx" "norun" "forcedl" "nohash"
	fi
	if [ ! -f "${datadir}/name-right.csv" ]; then
		fn_fetch_file_github "lgsm/data" "name-right.csv" "${datadir}" "nochmodx" "norun" "forcedl" "nohash"
	fi

	# generate instance uuid
	if [ -n "$(command -v uuidgen 2> /dev/null)" ]; then
		uuid="$(uuidgen)"
	else
		uuid="$(cat /proc/sys/kernel/random/uuid)"
	fi

	nameleft="$(shuf -n 1 "${datadir}/name-left.csv")"
	nameright="$(shuf -n 1 "${datadir}/name-right.csv")"
	echo "instance_${nameleft}_${nameright}_${uuid}" > "${datadir}/uuid-${selfname}.txt"
	# generate install uuid if missing
	if [ ! -f "${datadir}/uuid-install.txt" ]; then
		echo "${nameleft}_${nameright}_${uuid}" > "${datadir}/uuid-install.txt"
	fi
fi

uuidinstance=$(cat "${datadir}/uuid-${selfname}.txt")
uuidinstall=$(cat "${datadir}/uuid-install.txt")
# machine-id is a unique id set on OS install
uuidhardware=$(cat "/etc/machine-id")

# results are rounded up to reduce number of different results in analytics.
# nearest 100Mhz.
cpuusedmhzroundup="$(((cpuusedmhz + 99) / 100 * 100))"
# nearest 100MB
memusedmbroundup="$(((memusedmb + 99) / 100 * 100))"

# Convert any commas to dots.
physmemtotal="${physmemtotal//,/.}"

apisecret="A-OzP02TSMWt4_vHi6ZpUw"
measurementid="G-0CR8V7EMT5"

# Sending stats to Google Analytics GA4
payload="{
	\"client_id\": \"${uuidinstance}\",
	\"events\": [
		{
		\"name\": \"LinuxGSM\",
		\"params\": {
			\"cpuusedmhzroundup\": \"${cpuusedmhzroundup}\",
			\"diskused\": \"${serverfilesdu}\",
			\"distro\": \"${distroname}\",
			\"game\": \"${gamename}\",
			\"memusedmbroundup\": \"${memusedmbroundup}\",
			\"ramused\": \"${memusedmbroundup}\",
			\"servercpu\": \"${cpumodel} ${cpucores} cores\",
			\"servercpufreq\": \"${cpufreqency} x${cpucores}\",
			\"serverdisk\": \"${totalspace}\",
			\"serverfilesdu\": \"${serverfilesdu}\",
			\"serverram\": \"${physmemtotal}\",
			\"serverramgb\": \"${physmemtotalgb}\",
			\"uuidhardware\": \"${uuidhardware}\",
			\"uuidinstall\": \"${uuidinstall}\",
			\"uuidinstance\": \"${uuidinstance}\",
			\"version\": \"${version}\",
			\"virtualenvironment\": \"${virtualenvironment}\",
			\"tmuxversion\": \"${tmuxversion}\",
			\"java\": \"${javaversion}\"
			}
		}
	]
}"

fn_alert_payload() {
	alertpayload="{
	\"client_id\": \"${uuidinstance}\",
	\"events\": [
		{
		\"name\": \"LinuxGSM\",
		\"params\": {
			\"alert\": \"${alerttype}\"
			}
		}
	]
}"
}

curl -X POST "https://www.google-analytics.com/mp/collect?api_secret=A-OzP02TSMWt4_vHi6ZpUw&measurement_id=G-0CR8V7EMT5" -H "Content-Type: application/json" -d "${payload}"

if [ "${discordalert}" == "on" ]; then
	alerttype="discord"
	fn_alert_payload
	curl -X POST "https://www.google-analytics.com/mp/collect?api_secret=${apisecret}&measurement_id=${measurementid}" -H "Content-Type: application/json" -d "${alertpayload}"
fi
if [ "${emailalert}" == "on" ]; then
	alerttype="email"
	fn_alert_payload
	curl -X POST "https://www.google-analytics.com/mp/collect?api_secret=${apisecret}&measurement_id=${measurementid}" -H "Content-Type: application/json" -d "${alertpayload}"
fi
if [ "${gotifyalert}" == "on" ]; then
	alerttype="gotify"
	fn_alert_payload
	curl -X POST "https://www.google-analytics.com/mp/collect?api_secret=${apisecret}&measurement_id=${measurementid}" -H "Content-Type: application/json" -d "${alertpayload}"
fi
if [ "${iftttalert}" == "on" ]; then
	alerttype="ifttt"
	fn_alert_payload
	curl -X POST "https://www.google-analytics.com/mp/collect?api_secret=${apisecret}&measurement_id=${measurementid}" -H "Content-Type: application/json" -d "${alertpayload}"
fi
if [ "${pushbulletalert}" == "on" ]; then
	alerttype="pushbullet"
	fn_alert_payload
	curl -X POST "https://www.google-analytics.com/mp/collect?api_secret=${apisecret}&measurement_id=${measurementid}" -H "Content-Type: application/json" -d "${alertpayload}"
fi
if [ "${pushoveralert}" == "on" ]; then
	alerttype="pushover"
	fn_alert_payload
	curl -X POST "https://www.google-analytics.com/mp/collect?api_secret=${apisecret}&measurement_id=${measurementid}" -H "Content-Type: application/json" -d "${alertpayload}"
fi
if [ "${rocketchatalert}" == "on" ]; then
	alerttype="rocketchat"
	fn_alert_payload
	curl -X POST "https://www.google-analytics.com/mp/collect?api_secret=${apisecret}&measurement_id=${measurementid}" -H "Content-Type: application/json" -d "${alertpayload}"
fi
if [ "${slackalert}" == "on" ]; then
	alerttype="slack"
	fn_alert_payload
	curl -X POST "https://www.google-analytics.com/mp/collect?api_secret=${apisecret}&measurement_id=${measurementid}" -H "Content-Type: application/json" -d "${alertpayload}"
fi
if [ "${telegramalert}" == "on" ]; then
	alerttype="telegram"
	fn_alert_payload
	curl -X POST "https://www.google-analytics.com/mp/collect?api_secret=${apisecret}&measurement_id=${measurementid}" -H "Content-Type: application/json" -d "${alertpayload}"
fi

fn_script_log_info "Send LinuxGSM stats"
fn_script_log_info "* uuid-${selfname}: ${uuidinstance}"
fn_script_log_info "* uuid-install: ${uuidinstall}"
fn_script_log_info "* uuid-hardware: ${uuidhardware}"
fn_script_log_info "* Game Name: ${gamename}"
fn_script_log_info "* Distro Name: ${distroname}"
fn_script_log_info "* Game Server CPU Used: ${cpuusedmhzroundup}MHz"
fn_script_log_info "* Game Server RAM Used: ${memusedmbroundup}MB"
fn_script_log_info "* Game Server Disk Used: ${serverfilesdu}"
fn_script_log_info "* Server CPU Model: ${cpumodel}"
fn_script_log_info "* Server CPU Frequency: ${cpufreqency}"
fn_script_log_info "* Server RAM: ${physmemtotal}"
fn_script_log_info "* Server Disk: ${totalspace}"
fn_script_log_info "* Virtual Environment: ${virtualenvironment}"
fn_script_log_info "* LinuxGSM Version: ${version}"
fn_script_log_info "* Enabled Alerts"

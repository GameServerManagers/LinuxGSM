#!/bin/bash
# LinuxGSM info_stats.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Collect optional Stats sent to LinuxGSM project.

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
uuidreport="${uuidinstance##*_}"

# results are rounded up to reduce number of different results.
# nearest 100Mhz.
cpuusedmhzroundup="$(((cpuusedmhz + 99) / 100 * 100))"
# nearest 100MB
memusedmbroundup="$(((memusedmb + 99) / 100 * 100))"

statsdate="$(date -u +%F)"
statsstamp="${datadir}/stats-last-sent-${selfname}"

if [ "$(cat "${statsstamp}" 2> /dev/null)" != "${statsdate}" ] && [ "$(command -v jq 2> /dev/null)" ]; then
	echo "${statsdate}" > "${statsstamp}"

	statscores="${cpucores}"
	if [[ ! "${statscores}" =~ ^[0-9]+$ ]]; then
		statscores="${cpulogicalcores}"
	fi
	statsramgb="$(awk -v mb="${physmemtotalmb}" 'BEGIN{printf "%.1f", mb / 1024}')"
	statsdiskgb="$(LC_ALL=C df -BG -P "${rootdir}" 2> /dev/null | awk 'NR==2{gsub("G","",$2); print $2}')"
	statsfilesgb="$(awk -v v="${serverfilesdu}" 'BEGIN{n=v+0; u=substr(v,length(v)); if(u=="K")n/=1048576; else if(u=="M")n/=1024; else if(u=="T")n*=1024; printf "%.2f", n}')"

	statspayload="$(jq -cn \
		--arg uuid "${uuidreport}" \
		--arg game "${gamename}" \
		--arg distro "${distroname}" \
		--arg version "${version}" \
		--arg virt "${virtualenvironment}" \
		--arg cores "${statscores}" \
		--arg ram "${statsramgb}" \
		--arg disk "${statsdiskgb}" \
		--arg ramused "${memusedmbroundup}" \
		--arg cpuused "${cpuusedmhzroundup}" \
		--arg filesgb "${statsfilesgb}" \
		'{uuid: $uuid, game: $game, distro: $distro, version: $version, virt: $virt, cpu_cores: ($cores | tonumber? // 0), ram_gb: ($ram | tonumber? // 0), disk_gb: ($disk | tonumber? // 0)}
		+ (if ($ramused | tonumber? // 0) > 0 then {ram_used_mb: ($ramused | tonumber)} else {} end)
		+ (if ($cpuused | tonumber? // 0) > 0 then {cpu_used_mhz: ($cpuused | tonumber)} else {} end)
		+ (if ($filesgb | tonumber? // 0) > 0 then {disk_used_gb: ($filesgb | tonumber)} else {} end)' 2> /dev/null)"

	if [ -n "${statspayload}" ]; then
		curl -sS -f --max-time 5 -X POST "https://usage.linuxgsm.com/v1/report" -H "Content-Type: application/json" -d "${statspayload}" > /dev/null 2>&1
	fi

	fn_script_log_info "Send LinuxGSM stats"
	fn_script_log_info "* uuid-${selfname}: ${uuidreport}"
	fn_script_log_info "* Game Name: ${gamename}"
	fn_script_log_info "* Distro Name: ${distroname}"
	fn_script_log_info "* LinuxGSM Version: ${version}"
	fn_script_log_info "* Virtual Environment: ${virtualenvironment}"
	fn_script_log_info "* Game Server CPU Used: ${cpuusedmhzroundup}MHz"
	fn_script_log_info "* Game Server RAM Used: ${memusedmbroundup}MB"
	fn_script_log_info "* Game Server Disk Used: ${serverfilesdu}"
	fn_script_log_info "* Server CPU Cores: ${statscores}"
	fn_script_log_info "* Server RAM: ${statsramgb}GB"
	fn_script_log_info "* Server Disk: ${statsdiskgb}GB"
fi

apisecret="A-OzP02TSMWt4_vHi6ZpUw"
measurementid="G-0CR8V7EMT5"

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
if [ "${matrixalert}" == "on" ]; then
	alerttype="matrix"
	fn_alert_payload
	curl -X POST "https://www.google-analytics.com/mp/collect?api_secret=${apisecret}&measurement_id=${measurementid}" -H "Content-Type: application/json" -d "${alertpayload}"
fi
if [ "${ntfyalert}" == "on" ]; then
	alerttype="ntfy"
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

fn_script_log_info "Enabled Alerts"

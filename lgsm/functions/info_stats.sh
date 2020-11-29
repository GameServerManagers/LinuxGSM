#!/bin/bash
# LinuxGSM info_stats.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Collect optional Stats sent to LinuxGSM project.
# Uses Google analytics.

local modulegroup="INFO"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_send_ga_data(){
	curl --connect-timeout 10 -s https://www.google-analytics.com/collect -d "$@" 2>&1
}

info_distro.sh

# remove uuid that was used in v20.2.0 and below
if [ -f "${datadir}/uuid.txt" ]; then
	rm "${datadir:?}/uuid.txt"
fi

# generate uuid's
# this consists of a standard uuid and a docker style name
# to allow human readable uuid's.
# e.g angry_proskuriakova_38a9ef76-4ae3-46a6-a895-7af474831eba

if [ ! -f "${datadir}/uuid-${selfname}.txt" ]||[ ! -f "${datadir}/uuid-install.txt" ]; then
	# download dictionary words
	if [ ! -f "${datadir}/name-left.csv" ]; then
		fn_fetch_file_github "lgsm/data" "name-left.csv" "${datadir}" "nochmodx" "norun" "forcedl" "nomd5"
	fi
	if [ ! -f "${datadir}/name-right.csv" ]; then
		fn_fetch_file_github "lgsm/data" "name-right.csv" "${datadir}" "nochmodx" "norun" "forcedl" "nomd5"
	fi

	# generate instance uuid
	if [ -n "$(command -v uuidgen 2>/dev/null)" ]; then
		uuid="$(uuidgen)"
	else
		uuid="$(cat /proc/sys/kernel/random/uuid)"
	fi

	nameleft="$(shuf -n 1 "${datadir}/name-left.csv")"
	nameright="$(shuf -n 1 "${datadir}/name-right.csv")"
	echo "instance_${nameleft}_${nameright}_${uuid}" > "${datadir}/uuid-${selfname}.txt"
	# generate install uuid if missing
	if [ ! -f "${datadir}/uuid-install.txt" ];then
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
memusedroundup="$(((memused + 99) / 100 * 100))"

# Spliting the metrics in to 3 propertys allows more accurate metrics on numbers of invidual instances, installs and hardware.
# Instance Property - UA-165287622-1
# Install Property - UA-165287622-2
# Hardware Property - UA-165287622-3

## loop to all Google Analytics ids + UUID
for loopdata in {"UA-165287622-1:${uuidinstance}","UA-165287622-2:${uuidinstall}","UA-165287622-3:${uuidhardware}"}; do
	# ID for GA
	gatid=$(echo "${loopdata}" | awk -F: '{print $1}')
	# get uuid for data
	uuid=$(echo "${loopdata}" | awk -F: '{print $2}')
	## Distro.
	fn_send_ga_data "tid=${gatid}&aip=1&cid=${uuid}&t=event&ec=distro&ea=${distroname}&el=${gamename}&v=1"
	## Game Server Name.
	fn_send_ga_data "tid=${gatid}&aip=1&cid=${uuid}&t=event&ec=game&ea=${gamename}&el=${gamename}&v=1"
	## LinuxGSM Version.
	fn_send_ga_data "tid=${gatid}&aip=1&cid=${uuid}&t=event&ec=version&ea=${version}&el=${gamename}&v=1"
	## CPU usage of a game server.
	if [ -n "${cpuusedmhzroundup}" ]; then
		fn_send_ga_data "tid=${gatid}&aip=1&cid=${uuid}&t=event&ec=cpuused&ea=${cpuusedmhzroundup}MHz&el=${gamename}&v=1"
	fi
	## Ram usage of a game server.
	if [ -n "${memusedroundup}" ]; then
		fn_send_ga_data "tid=${gatid}&aip=1&cid=${uuid}&t=event&ec=ramused&ea=${memusedroundup}MB&el=${gamename}&v=1"
	fi
	## Disk usage of a game server.
	if [ -n "${serverfilesdu}" ]; then
		fn_send_ga_data "tid=${gatid}&aip=1&cid=${uuid}&t=event&ec=diskused&ea=${serverfilesdu}&el=${gamename}&v=1"
	fi
	## CPU Model.
	if [ -n "${cpumodel}" ]; then
		fn_send_ga_data "tid=${garid}&aip=1&cid=${uuid}&t=event&ec=servercpu&ea=${cpumodel} ${cpucores} cores&el=${gamename}&v=1"
	fi
	## CPU Frequency.
	if [ -n "${cpufreqency}" ]; then
		fn_send_ga_data "tid=${gatid}&aip=1&cid=${uuid}&t=event&ec=servercpufreq&ea=${cpufreqency} x${cpucores}&el=${gamename}&v=1"
	fi
	## Server RAM.
	if [ -n "${physmemtotal}" ]; then
		fn_send_ga_data "tid=${gatid}&aip=1&cid=${uuid}&t=event&ec=serverram&ea=${physmemtotal}&el=${gamename}&v=1"
	fi
	## Server Disk.
	if [ -n "${totalspace}" ]; then
		fn_send_ga_data "tid=${gatid}&aip=1&cid=${uuid}&t=event&ec=serverdisk&ea=${totalspace}&el=${gamename}&v=1"
	fi
	## Summary Stats
	fn_send_ga_data "tid=${gatid}&aip=1&cid=${uuid}&t=event&ec=summary&ea=GAME: ${gamename} | DISTRO: ${distroname} | CPU MODEL: ${cpumodel} ${cpucores} cores | RAM: ${physmemtotal} | DISK: ${totalspace}&v=1"
done

fn_script_log_info "Send LinuxGSM stats"
fn_script_log_info "* uuid-${selfname}: ${uuidinstance}"
fn_script_log_info "* uuid-install: ${uuidinstall}"
fn_script_log_info "* uuid-hardware: ${uuidhardware}"
fn_script_log_info "* Game Name: ${gamename}"
fn_script_log_info "* Distro Name: ${distroname}"
fn_script_log_info "* Game Server CPU Used: ${cpuusedmhzroundup}MHz"
fn_script_log_info "* Game Server RAM Used: ${memusedroundup}MB"
fn_script_log_info "* Game Server Disk Used: ${serverfilesdu}"
fn_script_log_info "* Server CPU Model: ${cpumodel}"
fn_script_log_info "* Server CPU Frequency: ${cpufreqency}"
fn_script_log_info "* Server RAM: ${physmemtotal}"
fn_script_log_info "* Server Disk: ${totalspace}"

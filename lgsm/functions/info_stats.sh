#!/bin/bash
# LinuxGSM info_stats.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Collect optional Stats sent to LinuxGSM project.
# Uses Google analytics.

info_distro.sh

# remove uuid that was used in v20.2.0 and below
if [ -f "${datadir}/uuid.txt" ]; then
	rm "${datadir:?}/uuid.txt"
fi

# generate uuid's
# this consists of a standard uuid and a docker style name
# to allow human readable uuid's.
# e.g angry_proskuriakova_38a9ef76-4ae3-46a6-a895-7af474831eba

if [ ! -f "${datadir}/uuid-${selfname}.txt" ]; then
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

## Distro.
curl https://www.google-analytics.com/collect -d "tid=UA-165287622-1" -d "aip=1" -d "cid=${uuidinstance}" -d "t=event" -d "ec=distro" -d "ea=${distroname}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
curl https://www.google-analytics.com/collect -d "tid=UA-165287622-2" -d "aip=1" -d "cid=${uuidinstall}" -d "t=event" -d "ec=distro" -d "ea=${distroname}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
curl https://www.google-analytics.com/collect -d "tid=UA-165287622-3" -d "aip=1" -d "cid=${uuidhardware}" -d "t=event" -d "ec=distro" -d "ea=${distroname}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1

## Game Server Name.
curl https://www.google-analytics.com/collect -d "tid=UA-165287622-1" -d "aip=1" -d "cid=${uuidinstance}" -d "t=event" -d "ec=game" -d "ea=${gamename}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
curl https://www.google-analytics.com/collect -d "tid=UA-165287622-2" -d "aip=1" -d "cid=${uuidinstall}" -d "t=event" -d "ec=game" -d "ea=${gamename}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
curl https://www.google-analytics.com/collect -d "tid=UA-165287622-3" -d "aip=1" -d "cid=${uuidhardware}" -d "t=event" -d "ec=game" -d "ea=${gamename}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1

## LinuxGSM Version.
curl https://www.google-analytics.com/collect -d "tid=UA-165287622-1" -d "aip=1" -d "cid=${uuidinstance}" -d "t=event" -d "ec=version" -d "ea=${version}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
curl https://www.google-analytics.com/collect -d "tid=UA-165287622-2" -d "aip=1" -d "cid=${uuidinstall}" -d "t=event" -d "ec=version" -d "ea=${version}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
curl https://www.google-analytics.com/collect -d "tid=UA-165287622-3" -d "aip=1" -d "cid=${uuidhardware}" -d "t=event" -d "ec=version" -d "ea=${version}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1

## CPU usage of a game server.
if [ -n "${cpuusedmhzroundup}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-1" -d "aip=1" -d "cid=${uuidinstance}" -d "t=event" -d "ec=cpuused" -d "ea=${cpuusedmhzroundup}MHz" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-2" -d "aip=1" -d "cid=${uuidinstall}" -d "t=event" -d "ec=cpuused" -d "ea=${cpuusedmhzroundup}MHz" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-3" -d "aip=1" -d "cid=${uuidhardware}" -d "t=event" -d "ec=cpuused" -d "ea=${cpuusedmhzroundup}MHz" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi
## Ram usage of a game server.
if [ -n "${memusedroundup}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-1" -d "aip=1" -d "cid=${uuidinstance}" -d "t=event" -d "ec=ramused" -d "ea=${memusedroundup}MB" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-2" -d "aip=1" -d "cid=${uuidinstall}" -d "t=event" -d "ec=ramused" -d "ea=${memusedroundup}MB" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-3" -d "aip=1" -d "cid=${uuidhardware}" -d "t=event" -d "ec=ramused" -d "ea=${memusedroundup}MB" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi
## Disk usage of a game server.
if [ -n "${serverfilesdu}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-1" -d "aip=1" -d "cid=${uuidinstance}" -d "t=event" -d "ec=diskused" -d "ea=${serverfilesdu}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-2" -d "aip=1" -d "cid=${uuidinstall}" -d "t=event" -d "ec=diskused" -d "ea=${serverfilesdu}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-3" -d "aip=1" -d "cid=${uuidhardware}" -d "t=event" -d "ec=diskused" -d "ea=${serverfilesdu}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi

## CPU Model.
if [ -n "${cpumodel}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-1" -d "aip=1" -d "cid=${uuidinstance}" -d "t=event" -d "ec=servercpu" -d "ea=${cpumodel} ${cpucores} cores" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-2" -d "aip=1" -d "cid=${uuidinstall}" -d "t=event" -d "ec=servercpu" -d "ea=${cpumodel} ${cpucores} cores" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-3" -d "aip=1" -d "cid=${uuidhardware}" -d "t=event" -d "ec=servercpu" -d "ea=${cpumodel} ${cpucores} cores" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1

fi

## CPU Frequency.
if [ -n "${cpufreqency}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-1" -d "aip=1" -d "cid=${uuidinstance}" -d "t=event" -d "ec=servercpufreq" -d "ea=${cpufreqency} x${cpucores}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-2" -d "aip=1" -d "cid=${uuidinstall}" -d "t=event" -d "ec=servercpufreq" -d "ea=${cpufreqency} x${cpucores}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-3" -d "aip=1" -d "cid=${uuidhardware}" -d "t=event" -d "ec=servercpufreq" -d "ea=${cpufreqency} x${cpucores}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi

## Server RAM.
if [ -n "${physmemtotal}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-1" -d "aip=1" -d "cid=${uuidinstance}" -d "t=event" -d "ec=serverram" -d "ea=${physmemtotal}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-2" -d "aip=1" -d "cid=${uuidinstall}" -d "t=event" -d "ec=serverram" -d "ea=${physmemtotal}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-3" -d "aip=1" -d "cid=${uuidhardware}" -d "t=event" -d "ec=serverram" -d "ea=${physmemtotal}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi

## Server Disk.
if [ -n "${totalspace}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-1" -d "aip=1" -d "cid=${uuidinstance}" -d "t=event" -d "ec=serverdisk" -d "ea=${totalspace}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-2" -d "aip=1" -d "cid=${uuidinstall}" -d "t=event" -d "ec=serverdisk" -d "ea=${totalspace}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
	curl https://www.google-analytics.com/collect -d "tid=UA-165287622-3" -d "aip=1" -d "cid=${uuidhardware}" -d "t=event" -d "ec=serverdisk" -d "ea=${totalspace}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi

## Summary Stats
curl https://www.google-analytics.com/collect -d "tid=UA-165287622-1" -d "aip=1" -d "cid=${uuidinstance}" -d "t=event" -d "ec=summary" -d "ea=GAME: ${gamename} | DISTRO: ${distroname} | CPU MODEL: ${cpumodel} ${cpucores} cores | RAM: ${physmemtotal} | DISK: ${totalspace}" -d "v=1" > /dev/null 2>&1
curl https://www.google-analytics.com/collect -d "tid=UA-165287622-2" -d "aip=1" -d "cid=${uuidinstall}" -d "t=event" -d "ec=summary" -d "ea=GAME: ${gamename} | DISTRO: ${distroname} | CPU MODEL: ${cpumodel} ${cpucores} cores | RAM: ${physmemtotal} | DISK: ${totalspace}" -d "v=1" > /dev/null 2>&1
curl https://www.google-analytics.com/collect -d "tid=UA-165287622-3" -d "aip=1" -d "cid=${uuidhardware}" -d "t=event" -d "ec=summary" -d "ea=GAME: ${gamename} | DISTRO: ${distroname} | CPU MODEL: ${cpumodel} ${cpucores} cores | RAM: ${physmemtotal} | DISK: ${totalspace}" -d "v=1" > /dev/null 2>&1

fn_script_log_info "Send LinuxGSM stats"
fn_script_log_info "* UUID: ${uuidinstance}"
fn_script_log_info "* Game Name: ${gamename}"
fn_script_log_info "* Distro Name: ${distroname}"
fn_script_log_info "* Game Server CPU Used: ${cpuusedmhzroundup}MHz"
fn_script_log_info "* Game Server RAM Used: ${memusedroundup}MB"
fn_script_log_info "* Game Server Disk Used: ${serverfilesdu}"
fn_script_log_info "* Server CPU Model: ${cpumodel}"
fn_script_log_info "* Server CPU Frequency: ${cpufreqency}"
fn_script_log_info "* Server RAM: ${physmemtotal}"
fn_script_log_info "* Server Disk: ${totalspace}"

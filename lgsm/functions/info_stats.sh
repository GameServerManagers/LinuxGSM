#!/bin/bash
# LinuxGSM info_stats.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Optional Stats to send to LinuxGSM Developer
# Uses Google analytics

info_distro.sh
# generate uuid
if [ ! -f "${datadir}/uuid.txt" ]; then
	mkdir -p "${datadir}"
	touch "${datadir}/uuid.txt"
	if [ "$(command -v uuidgen 2>/dev/null)" ]; then
		uuidgen > "${datadir}/uuid.txt"
	else
		cat /proc/sys/kernel/random/uuid > "${datadir}/uuid.txt"
	fi
fi

uuid=$(cat "${datadir}/uuid.txt")
# results are rounded up to reduce number of different results in analytics.
# nearest 100Mhz.
cpuusedmhzroundup=$(((cpuusedmhz + 99) / 100 * 100))
# nearest 100MB
memusedroundup=$(((memused + 99) / 100 * 100))

## Distro.
curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=distro" -d "ea=${distroname}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
## Game Server Name.
curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=game" -d "ea=${gamename}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
## LinuxGSM Version.
curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=version" -d "ea=${version}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1

## CPU usage of a game server.
if [ "${cpuusedmhzroundup}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=cpuused" -d "ea=${cpuusedmhzroundup}MHz" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi
## Ram usage of a game server.
if [ "${memusedroundup}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=ramused" -d "ea=${memusedroundup}MB" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi
## Disk usage of a game server.
if [ "${serverfilesdu}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=diskused" -d "ea=${serverfilesdu}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi

## CPU Model.
if [ "${cpumodel}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=servercpu" -d "ea=${cpumodel} ${cpucores} cores" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi

## CPU Frequency.
if [ "${cpufreqency}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=servercpufreq" -d "ea=${cpufreqency} x${cpucores}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi

## Server RAM.
if [ "${physmemtotal}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=serverram" -d "ea=${physmemtotal}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi

## Server Disk.
if [ "${totalspace}" ]; then
	curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=serverdisk" -d "ea=${totalspace}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
fi

## Summary Stats
curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=summary" -d "ea=GAME: ${gamename} | DISTRO: ${distroname} | CPU MODEL: ${cpumodel} ${cpucores} cores | RAM: ${physmemtotal} | DISK: ${totalspace}" -d "v=1" > /dev/null 2>&1

fn_script_log_info "Send LinuxGSM stats"
fn_script_log_info "* UUID: ${uuid}"
fn_script_log_info "* Game Name: ${gamename}"
fn_script_log_info "* Distro Name: ${distroname}"
fn_script_log_info "* Game Server CPU Used: ${cpuusedmhzroundup}MHz"
fn_script_log_info "* Game Server RAM Used: ${memusedroundup}MB"
fn_script_log_info "* Game Server Disk Used: ${serverfilesdu}"
fn_script_log_info "* Server CPU Model: ${cpumodel}"
fn_script_log_info "* Server CPU Frequency: ${cpufreqency}"
fn_script_log_info "* Server RAM: ${physmemtotal}"
fn_script_log_info "* Server Disk: ${totalspace}"

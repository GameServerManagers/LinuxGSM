#!/bin/bash
# LinuxGSM info_distro.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Variables providing useful info on the Operating System such as disk and performace info.
# Used for command_details.sh, command_debug.sh and alert.sh.

local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

### Distro information

## Distro
# Returns architecture, kernel and distro/os.
arch=$(uname -m)
kernel=$(uname -r)

# Distro name - Ubuntu 16.04
# Distro Version - 16.04
# Distro ID - ubuntu
if [ -f "/etc/os-release" ]; then
	distroname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="')
	distroversion=$(grep VERSION_ID /etc/os-release | sed 's/VERSION_ID=//g' | sed 's/\"//g')
	distroid=$(grep ID /etc/os-release | grep -v _ID | grep -v ID_ | sed 's/ID=//g')
elif [ -n "$(command -v lsb_release)" ]; then
	distroname="$(lsb_release -sd)"
	distroversion="$(lsb_release -sr)"
	distroid=$(lsb_release -sc)
elif [ -f "/etc/debian_version" ]; then
	distroname="Debian $(cat /etc/debian_version)"
	distroversion="$(cat /etc/debian_version)"
	distroid="debian"
elif [ -f "/etc/redhat-release" ]; then
	distroname=$(cat /etc/redhat-release)
	distroversion=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos|fedora" | cut -d"-" -f3)
	distroid="$(wk '{print $1;}' /etc/redhat-release)"
fi

## Glibc version
# e.g: 1.17
glibcversion="$(ldd --version | sed -n '1s/.* //p')"

## tmux version
# e.g: tmux 1.6
if [ -z "$(command -V tmux 2>/dev/null)" ]; then
	tmuxv="${red}NOT INSTALLED!${default}"
else
	if [ "$(tmux -V|sed "s/tmux //" | sed -n '1 p' | tr -cd '[:digit:]')" -lt "16" ] 2>/dev/null; then
		tmuxv="$(tmux -V) (>= 1.6 required for console log)"
	else
		tmuxv=$(tmux -V)
	fi
fi

## Uptime
uptime=$(</proc/uptime)
uptime=${uptime/[. ]*/}
minutes=$(( uptime/60%60 ))
hours=$(( uptime/60/60%24 ))
days=$(( uptime/60/60/24 ))

### Performance information

## Average server load
load=$(uptime|awk -F 'load average: ' '{ print $2 }')

## Memory information
# Available RAM and swap.

# Older versions of free do not support -h option.
if [ "$(free -h > /dev/null 2>&1; echo $?)" -ne "0" ]; then
	humanreadable="-m"
else
	humanreadable="-h"
fi

physmemtotal=$(free ${humanreadable} | awk '/Mem:/ {print $2}')
physmemtotalmb=$(free -m | awk '/Mem:/ {print $2}')
physmemused=$(free ${humanreadable} | awk '/Mem:/ {print $3}')
physmemfree=$(free ${humanreadable} | awk '/Mem:/ {print $4}')
oldfree=$(free ${humanreadable} | awk '/cache:/')
if [ -n "${oldfree}" ]; then
	physmemavailable="n/a"
	physmemcached="n/a"
else
	physmemavailable=$(free ${humanreadable} | awk '/Mem:/ {print $7}')
	physmemcached=$(free ${humanreadable} | awk '/Mem:/ {print $5}')
fi

swaptotal=$(free ${humanreadable} | awk '/Swap:/ {print $2}')
swapused=$(free ${humanreadable} | awk '/Swap:/ {print $3}')
swapfree=$(free ${humanreadable} | awk '/Swap:/ {print $4}')

### Disk information

## Available disk space on the partition.
filesystem=$(df -hP "${rootdir}" | grep -v "Filesystem" | awk '{print $1}')
totalspace=$(df -hP "${rootdir}" | grep -v "Filesystem" | awk '{print $2}')
usedspace=$(df -hP "${rootdir}" | grep -v "Filesystem" | awk '{print $3}')
availspace=$(df -hP "${rootdir}" | grep -v "Filesystem" | awk '{print $4}')

## LinuxGSM used space total.
rootdirdu=$(du -sh "${rootdir}" 2> /dev/null | awk '{print $1}')
if [ -z "${rootdirdu}" ]; then
	rootdirdu="0M"
fi

## LinuxGSM used space in serverfiles dir.
serverfilesdu=$(du -sh "${serverfiles}" 2> /dev/null | awk '{print $1}')
if [ -z "${serverfilesdu}" ]; then
	serverfilesdu="0M"
fi

## LinuxGSM used space total minus backup dir.
rootdirduexbackup=$(du -sh --exclude="${backupdir}" "${serverfiles}" 2> /dev/null | awk '{print $1}')
if [ -z "${rootdirduexbackup}" ]; then
	rootdirduexbackup="0M"
fi

## Backup info
if [ -d "${backupdir}" ]; then
	# Used space in backups dir.
	backupdirdu=$(du -sh "${backupdir}" | awk '{print $1}')
	# If no backup dir, size is 0M
	if [ -z "${backupdirdu}" ]; then
		backupdirdu="0M"
	fi

	# number of backups set to 0 by default
	backupcount=0

	# If there are backups in backup dir.
	if [ $(find "${backupdir}" -name "*.tar.gz" | wc -l) -ne "0" ]; then
		# number of backups.
		backupcount=$(find "${backupdir}"/*.tar.gz | wc -l)
		# most recent backup.
		lastbackup=$(find "${backupdir}"/*.tar.gz | head -1)
		# date of most recent backup.
		lastbackupdate=$(date -r "${lastbackup}")
		# no of days since last backup.
		lastbackupdaysago=$(( ( $(date +'%s') - $(date -r "${lastbackup}" +'%s') )/60/60/24 ))
		# size of most recent backup.
		lastbackupsize=$(du -h "${lastbackup}" | awk '{print $1}')
	fi
fi

# External IP address
if [ -z "${extip}" ]; then
	extip=$(${curlpath} -m 3 ifconfig.co > "${tmpdir}/extip.txt" 2>/dev/null)
	if [ $? -ne 0 ]; then
		if [ -f "${tmpdir}/extip.txt" ]; then
			echo "${tmpdir}/extip.txt"
		else
			echo "x.x.x.x"
		fi
	fi
fi
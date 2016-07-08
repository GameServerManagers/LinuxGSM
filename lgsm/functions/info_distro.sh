#!/bin/bash
# LGSM info_distro.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Variables providing useful info on the Operating System such as disk and performace info.
# Used for command_details.sh, command_debug.sh and alert.sh.

local selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

### Distro infomation

## Distro
# Returns architecture, kernel and distro/os.
arch=$(uname -m)
kernel=$(uname -r)
if [ -n "$(command -v lsb_release)" ]; then
	os=$(lsb_release -s -d)
elif [ -f "/etc/debian_version" ]; then
	os="Debian $(cat /etc/debian_version)"
elif [ -f "/etc/redhat-release" ]; then
	os=$(cat /etc/redhat-release)
else
	os="$(uname -s) $(uname -r)"
fi

## Glibc version
# e.g: 1.17
glibcversion="$(ldd --version | sed -n '1s/.* //p')"

## tmux version
# e.g: tmux 1.6
if [ -z "$(command -v tmux)" ]; then
	tmuxv="\e[0;31mNOT INSTALLED!\e[0m"
elif [ "$(tmux -V|sed "s/tmux //"|sed -n '1 p'|tr -cd '[:digit:]')" -lt "16" ]; then
	tmuxv="$(tmux -V) (>= 1.6 required for console log)"
else
	tmuxv=$(tmux -V)
fi

## Uptime
uptime=$(</proc/uptime)
uptime=${uptime/[. ]*/}
minutes=$(( uptime/60%60 ))
hours=$(( uptime/60/60%24 ))
days=$(( uptime/60/60/24 ))


### Performance infomation

## Average server load
load=$(uptime|awk -F 'load average: ' '{ print $2 }')

## Memory Infomation
# Available RAM and swap.

# Older versions of free do not support -h option.
if [ "$(free -h > /dev/null 2>&1; echo $?)" -ne "0" ]; then
	humanreadable="-m"
else
	humanreadable="-h"
fi

physmemtotal=$(free ${humanreadable} | awk '/Mem:/ {print $2}')
physmemused=$(free ${humanreadable} | awk '/Mem:/ {print $3}')
physmemfree=$(free ${humanreadable} | awk '/Mem:/ {print $4}')
swaptotal=$(free ${humanreadable} | awk '/Swap:/ {print $2}')
swapused=$(free ${humanreadable} | awk '/Swap:/ {print $3}')
swapfree=$(free ${humanreadable} | awk '/Swap:/ {print $4}')


### Disk Infomation

## Available disk space on the partition.
filesystem=$(df -hP "${rootdir}" | grep -v "Filesystem" | awk '{print $1}')
totalspace=$(df -hP "${rootdir}" | grep -v "Filesystem" | awk '{print $2}')
usedspace=$(df -hP "${rootdir}" | grep -v "Filesystem" | awk '{print $3}')
availspace=$(df -hP "${rootdir}" | grep -v "Filesystem" | awk '{print $4}')

## LGSM used space total.
rootdirdu=$(du -sh "${rootdir}" 2> /dev/null | awk '{print $1}')
if [ -z "${rootdirdu}" ]; then
	rootdirdu="0M"
fi

## LGSM used space in serverfiles dir.
filesdirdu=$(du -sh "${filesdir}" 2> /dev/null | awk '{print $1}')
if [ -z "${filesdirdu}" ]; then
	filesdirdu="0M"
fi

## LGSM used space total minus backup dir.
rootdirduexbackup=$(du -sh --exclude="${backupdir}" "${filesdir}" 2> /dev/null | awk '{print $1}')
if [ -z "${rootdirduexbackup}" ]; then
	rootdirduexbackup="0M"
fi

## Backup info
if [ -d "${backupdir}" ]; then
	# used space in backups dir.
	backupdirdu=$(du -sh "${backupdir}" | awk '{print $1}')
	if [ -z "${backupdirdu}" ]; then
		backupdirdu="0M"
	fi

	# number of backups.
	backupcount=$(find "${backupdir}"/*.tar.gz | wc -l)
	# most recent backup.
	lastbackup=$(ls -t "${backupdir}"/*.tar.gz | head -1)
	# date of most recent backup.
	lastbackupdate=$(date -r "${lastbackup}")
	# size of most recent backup.
	lastbackupsize=$(du -h "${lastbackup}" | awk '{print $1}')

fi
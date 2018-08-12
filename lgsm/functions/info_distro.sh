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

# Distro Name - Ubuntu 16.04 LTS
# Distro Version - 16.04
# Distro ID - ubuntu
# Distro Codename - xenial

# Gathers distro info from various sources filling in missing gaps
distro_info_array=( os-release lsb_release hostnamectl debian_version redhat-release )
for distro_info in "${distro_info_array[@]}"
do
	if [ -f "/etc/os-release" ]&&[ "${distro_info}" == "os-release" ]; then
		distroname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="' | sed 's/\"//g')
		distroversion=$(grep VERSION_ID /etc/os-release | sed 's/VERSION_ID=//g' | sed 's/\"//g')
		distroid=$(grep ID /etc/os-release | grep -v _ID | grep -v ID_ | sed 's/ID=//g' | sed 's/\"//g')
		distrocodename=$(grep VERSION_CODENAME /etc/os-release | sed 's/VERSION_CODENAME=//g' | sed 's/\"//g')
	elif [ -n "$(command -v lsb_release 2>/dev/null)" ]&&[ "${distro_info}" == "lsb_release" ]; then
		if [ -z "${distroname}" ];then
			distroname="$(lsb_release -sd)"
		elif [ -z "${distroversion}" ];then
			distroversion="$(lsb_release -sr)"
		elif [ -z "${distroid}" ];then
			distroid=$(lsb_release -si)
		elif [ -z "${distrocodename}" ];then
			distrocodename=$(lsb_release -sc)
		fi
	elif [ -n "$(command -v hostnamectl 2>/dev/null)" ]&&[ "${distro_info}" == "hostnamectl" ]; then
		if [ -z "${distroname}" ];then
			distroname="$(hostnamectl | grep "Operating System" | sed 's/Operating System: //g')"
		fi
	elif [ -f "/etc/debian_version" ]&&[ "${distro_info}" == "debian_version" ]; then
		if [ -z "${distroname}" ];then
			distroname="Debian $(cat /etc/debian_version)"
		elif [ -z "${distroversion}" ];then
			distroversion="$(cat /etc/debian_version)"
		elif [ -z "${distroid}" ];then
			distroid="debian"
		fi
	elif [ -f "/etc/redhat-release" ]&&[ "${distro_info}" == "redhat-release" ]; then
		if [ -z "${distroname}" ];then
			distroname=$(cat /etc/redhat-release)
		elif [ -z "${distroversion}" ];then
			distroversion=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos|fedora" | cut -d"-" -f3)
		elif [ -z "${distroid}" ];then
			distroid="$(awk '{print $1}' /etc/redhat-release)"
		fi
	fi
done

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
physmemtotalmb=$(($(grep MemTotal /proc/meminfo | awk '{print $2}')/1024))
physmemtotal=$(numfmt --to=iec --from=iec --suffix=B "$(grep ^MemTotal /proc/meminfo | awk '{print $2}')K")
physmemfree=$(numfmt --to=iec --from=iec --suffix=B "$(grep ^MemAvailable /proc/meminfo | awk '{print $2}')K")
physmemused=$(numfmt --to=iec --from=iec --suffix=B "$(($(grep "^MemTotal\:" /proc/meminfo | awk '{print $2}')-$(grep "^MemFree\:" /proc/meminfo | awk '{print $2}')-$(grep "^Buffers\:" /proc/meminfo | awk '{print $2}')-$(grep "^Cached\:" /proc/meminfo | awk '{print $2}')-$(grep "^SReclaimable\:" /proc/meminfo | awk '{print $2}')))K")
{ # try
	physmemavailable=$(numfmt --to=iec --from=iec --suffix=B "$(grep ^MemAvailable /proc/meminfo | awk '{print $2}')K")
	physmemcached=$(numfmt --to=iec --from=iec --suffix=B "$(($(grep ^Cached /proc/meminfo | awk '{print $2}')+$(grep "^SReclaimable\:" /proc/meminfo | awk '{print $2}')))K")
} 2>/dev/null || { # fail silently, catch
	physmemavailable="n/a"
	physmemcached="n/a"
}

swaptotal=$(numfmt --to=iec --from=iec --suffix=B "$(grep ^SwapTotal /proc/meminfo | awk '{print $2}')K")
swapfree=$(numfmt --to=iec --from=iec --suffix=B "$(grep ^SwapFree /proc/meminfo | awk '{print $2}')K")
swapused=$(numfmt --to=iec --from=iec --suffix=B "$(($(grep ^SwapTotal /proc/meminfo | awk '{print $2}')-$(grep ^SwapFree /proc/meminfo | awk '{print $2}')))K")

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
	if [ "$(find "${backupdir}" -name "*.tar.gz" | wc -l)" -ne "0" ]; then
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

# Steam Master Server - checks if detected by master server
if [ "${ip}" ] && [ "${port}" ]; then
	if [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]||[ "${shortname}" == "jc2" ]||[ "${shortname}" == "ql" ]; then
		masterserver=$(${curlpath} -s 'https://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr='${ip}':'${port}'&format=json' | jq '.response.servers[]|.addr' | wc -l)
		if [ "${steammaster}" == "1" ]; then
			masterserver="true"
		else
			masterserver="false"
		fi
	fi
fi
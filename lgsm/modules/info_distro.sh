#!/bin/bash
# LinuxGSM info_distro.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Variables providing useful info on the Operating System such as disk and performace info.
# Used for command_details.sh, command_debug.sh and alert.sh.
# !Note: When adding variables to this script, ensure that they are also added to the command_dev_parse_distro_details.sh script.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

### Game Server pid
if [ "${status}" == "1" ]; then
	gameserverpid="$(tmux -L "${socketname}" list-sessions -F "#{session_name} #{pane_pid}" | grep "^${sessionname} " | awk '{print $NF}')"
	if [ "${engine}" == "source" ]; then
		srcdslinuxpid="$(ps -ef | grep -v grep | grep "${gameserverpid}" | grep srcds_linux | awk '{print $2}')"
	elif [ "${engine}" == "goldsrc" ]; then
		hldslinuxpid="$(ps -ef | grep -v grep | grep "${gameserverpid}" | grep hlds_linux | awk '{print $2}')"
	fi
fi
### Distro information

## Distro
# Returns architecture, kernel and distro/os.
arch="$(uname -m)"   # Architecture e.g. x86_64
kernel="$(uname -r)" # Kernel e.g. 2.6.32-042stab120.16

# Gathers distro info from various sources filling in missing gaps.
distro_info_array=(os-release lsb_release hostnamectl debian_version redhat-release)
for distro_info in "${distro_info_array[@]}"; do
	if [ -f "/etc/os-release" ] && [ "${distro_info}" == "os-release" ]; then
		distroname="$(grep "PRETTY_NAME" /etc/os-release | awk -F= '{gsub(/"/,"",$2);print $2}')"              # e.g. Ubuntu 22.04.3 LTS
		distroversion="$(grep "VERSION_ID" /etc/os-release | awk -F= '{gsub(/"/,"",$2);print $2}')"            # e.g. 22.04
		distroid="$(grep "ID=" /etc/os-release | grep -v _ID | awk -F= '{gsub(/"/,"",$2);print $2}')"          # e.g. ubuntu
		distroidlike="$(grep "ID_LIKE=" /etc/os-release | grep -v _ID | awk -F= '{gsub(/"/,"",$2);print $2}')" # e.g. debian
		distrocodename="$(grep "VERSION_CODENAME" /etc/os-release | awk -F= '{gsub(/"/,"",$2);print $2}')"     # e.g. jammy
		# Special var for rhel like distros to remove point in number e.g 8.4 to just 8.
		if [[ "${distroidlike}" == *"rhel"* ]] || [ "${distroid}" == "rhel" ]; then
			distroversionrh="$(sed -nr 's/^VERSION_ID="([0-9]*).+?"/\1/p' /etc/os-release)" # e.g. 8
		fi
	elif [ "$(command -v lsb_release 2> /dev/null)" ] && [ "${distro_info}" == "lsb_release" ]; then
		if [ -z "${distroname}" ]; then
			distroname="$(lsb_release -sd)" # e.g. Ubuntu 22.04.3 LTS
		elif [ -z "${distroversion}" ]; then
			distroversion="$(lsb_release -sr)" # e.g. 22.04
		elif [ -z "${distroid}" ]; then
			distroid="$(lsb_release -si)" # e.g. Ubuntu
		elif [ -z "${distrocodename}" ]; then
			distrocodename="$(lsb_release -sc)" # e.g. jammy
		fi
	elif [ "$(command -v hostnamectl 2> /dev/null)" ] && [ "${distro_info}" == "hostnamectl" ]; then
		if [ -z "${distroname}" ]; then
			distroname="$(hostnamectl | grep "Operating System" | sed 's/Operating System: //g')" # e.g. Ubuntu 22.04.3 LTS
		fi
	elif [ -f "/etc/debian_version" ] && [ "${distro_info}" == "debian_version" ]; then
		if [ -z "${distroname}" ]; then
			distroname="Debian $(cat /etc/debian_version)" # e.g. Debian bookworm/sid
		elif [ -z "${distroversion}" ]; then
			distroversion="$(cat /etc/debian_version)" # e.g. bookworm/sid
		elif [ -z "${distroid}" ]; then
			distroid="debian"
		fi
	elif [ -f "/etc/redhat-release" ] && [ "${distro_info}" == "redhat-release" ]; then
		if [ -z "${distroname}" ]; then
			distroname="$(cat /etc/redhat-release)" # e.g. Rocky Linux release 9.2 (Blue Onyx)
		elif [ -z "${distroversion}" ]; then
			distroversion="$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos|fedora|rocky|alma" | cut -d"-" -f3)" # e.g. 9.2
		elif [ -z "${distroid}" ]; then
			distroid="$(awk '{print $1}' /etc/redhat-release)" # e.g. Rocky
		fi
	fi
done

# Get virtual environment type.
if [ "$(command -v systemd-detect-virt 2> /dev/null)" ]; then
	virtualenvironment="$(systemd-detect-virt)" # e.g. kvm
fi

# distroversioncsv is used for selecting the correct distro csv in data directory
if [ -n "${distroversionrh}" ]; then
	distroversioncsv="${distroversionrh}" # e.g. 8
else
	distroversioncsv="${distroversion}" # e.g. 22.04
fi

# Check if distro supported by distro vendor.
# distro-info available in debian based distros.
if [ "$(command -v distro-info 2> /dev/null)" ]; then
	distrosunsupported="$(distro-info --unsupported)"
	distrosunsupported_array=("${distrosunsupported}")
	for distrounsupported in "${distrosunsupported_array[@]}"; do
		if [ "${distrounsupported}" == "${distrocodename}" ]; then
			distrosupport="unsupported"
			break
		else
			distrosupport="supported"
		fi
	done
elif [[ "${distroidlike}" == *"rhel"* ]] || [ "${distroid}" == "rhel" ]; then
	# RHEL/CentOS 7 EOL 2024-06-30. Will be unsupported after this date.
	if [ "${distroversionrh}" -lt "8" ] && [ "$(date +%s)" -lt "1719705600" ]; then
		distrosupport="unsupported"
	else
		distrosupport="supported"
	fi
fi

## Glibc version
glibcversion="$(ldd --version | sed -n '1s/.* //p')" # e.g: 2.17

## tmux version
if [ "$(command -V tmux 2> /dev/null)" ]; then
	tmuxversion="$(tmux -V | awk '{print $2}')" # e.g: tmux 3.3
fi

if [ "$(command -V java 2> /dev/null)" ]; then
	javaversion="$(java -version 2>&1 | grep "version")" # e.g: openjdk version "17.0.8.1" 2023-08-24
fi

if [ "$(command -v mono 2> /dev/null)" ]; then
	monoversion="$(mono --version 2>&1 | grep -Po '(?<=version )\d')" # e.g: 6
fi

if [ "$(command -v dotnet 2> /dev/null)" ]; then
	dotnetversion="$(dotnet --list-runtimes | grep -E 'Microsoft\.NETCore\.App' | awk '{print $2}')" # e.g: 6.0.0
fi

## Uptime
uptime="$(< /proc/uptime)"
uptime=${uptime/[. ]*/}
minutes="$((uptime / 60 % 60))"
hours="$((uptime / 60 / 60 % 24))"
days="$((uptime / 60 / 60 / 24))"

### Performance information

## Average server load
load="$(uptime | awk -F 'load average: ' '{ print $2 }')" # e.g 0.01, 0.05, 0.11

## CPU information
cpumodel="$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')" # e.g Intel(R) Xeon(R) CPU E5-2676 v3 @ 2.40GHz
cpucores="$(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)"
cpufreqency="$(awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')" # e.g 2394.503
# CPU usage of the game server pid
if [ -n "${gameserverpid}" ]; then
	cpuused="$(ps --forest -o pcpu -g "${gameserverpid}" | awk '{s+=$1} END {print s}')" # integer
	cpuusedmhz="$(echo "${cpufreqency} * ${cpuused} / 100" | bc)"                        # integer
fi

## Memory information
# Available RAM and swap.

# Newer distros can use numfmt to give more accurate results.
if [ "$(command -v numfmt 2> /dev/null)" ]; then
	# Issue #2005 - Kernel 3.14+ contains MemAvailable which should be used. All others will be calculated.

	# get the raw KB values of these fields.
	physmemtotalkb="$(grep MemTotal /proc/meminfo | awk '{print $2}')"            # integer
	physmemfreekb="$(grep ^MemFree /proc/meminfo | awk '{print $2}')"             # integer
	physmembufferskb="$(grep ^Buffers /proc/meminfo | awk '{print $2}')"          # integer
	physmemcachedkb="$(grep ^Cached /proc/meminfo | awk '{print $2}')"            # integer
	physmemreclaimablekb="$(grep ^SReclaimable /proc/meminfo | awk '{print $2}')" # integer

	# check if MemAvailable Exists.
	if grep -q ^MemAvailable /proc/meminfo; then
		physmemactualfreekb="$(grep ^MemAvailable /proc/meminfo | awk '{print $2}')" # integer
	else
		physmemactualfreekb="$((physmemfreekb + physmembufferskb + physmemcachedkb))" # integer
	fi

	# Available RAM and swap.
	physmemtotalmb="$(((physmemtotalkb + 512) / 1024))"                                                                                                       # integer                                                                                                     # integer
	physmemtotalgb="$(((physmemtotalmb + 512) / 1024))"                                                                                                       # integer                                                                                                   # integer
	physmemtotal="$(numfmt --to=iec --from=iec --suffix=B "${physmemtotalkb}K")"                                                                              # string
	physmemfree="$(numfmt --to=iec --from=iec --suffix=B "${physmemactualfreekb}K")"                                                                          # string
	physmemused="$(numfmt --to=iec --from=iec --suffix=B "$((physmemtotalkb - physmemfreekb - physmembufferskb - physmemcachedkb - physmemreclaimablekb))K")" # string
	physmemavailable="$(numfmt --to=iec --from=iec --suffix=B "${physmemactualfreekb}K")"                                                                     # string
	physmemcached="$(numfmt --to=iec --from=iec --suffix=B "$((physmemcachedkb + physmemreclaimablekb))K")"                                                   # string

	swaptotal="$(numfmt --to=iec --from=iec --suffix=B "$(grep ^SwapTotal /proc/meminfo | awk '{print $2}')K")"                                                          # string
	swapfree="$(numfmt --to=iec --from=iec --suffix=B "$(grep ^SwapFree /proc/meminfo | awk '{print $2}')K")"                                                            # string
	swapused="$(numfmt --to=iec --from=iec --suffix=B "$(($(grep ^SwapTotal /proc/meminfo | awk '{print $2}') - $(grep ^SwapFree /proc/meminfo | awk '{print $2}')))K")" # string
	# RAM usage of the game server pid
	if [ "${gameserverpid}" ]; then
		memusedmb="$(ps --forest -o rss -g "${gameserverpid}" | awk '{s+=$1} END {print s}' | awk '{$1/=1024;printf "%.0f",$1}{print $2}')" # integer
		memusedpct="$(ps --forest -o %mem -g "${gameserverpid}" | awk '{s+=$1} END {print s}')"                                             # integer
	fi
else
	# Older distros will need to use free.
	# Older versions of free do not support -h option.
	if [ "$(
		free -h > /dev/null 2>&1
		echo $?
	)" -ne "0" ]; then
		humanreadable="-m"
	else
		humanreadable="-h"
	fi
	physmemtotalmb="$(free -m | awk '/Mem:/ {print $2}')"             # integer
	physmemtotalgb="$(free -m | awk '/Mem:/ {print $2}')"             # integer
	physmemtotal="$(free ${humanreadable} | awk '/Mem:/ {print $2}')" # string
	physmemfree="$(free ${humanreadable} | awk '/Mem:/ {print $4}')"  # string
	physmemused="$(free ${humanreadable} | awk '/Mem:/ {print $3}')"  # string

	oldfree="$(free ${humanreadable} | awk '/cache:/')"
	if [ "${oldfree}" ]; then
		physmemavailable="n/a" # string
		physmemcached="n/a"    # string
	else
		physmemavailable="$(free ${humanreadable} | awk '/Mem:/ {print $7}')" # string
		physmemcached="$(free ${humanreadable} | awk '/Mem:/ {print $6}')"    # string
	fi

	swaptotal="$(free ${humanreadable} | awk '/Swap:/ {print $2}')" # string
	swapused="$(free ${humanreadable} | awk '/Swap:/ {print $3}')"  # string
	swapfree="$(free ${humanreadable} | awk '/Swap:/ {print $4}')"  # string
fi

### Disk information

## Available disk space on the partition.
filesystem="$(LC_ALL=C df -hP "${rootdir}" | tail -n 1 | awk '{print $1}')" # string e.g /dev/sda
totalspace="$(LC_ALL=C df -hP "${rootdir}" | tail -n 1 | awk '{print $2}')" # string e.g 20G
usedspace="$(LC_ALL=C df -hP "${rootdir}" | tail -n 1 | awk '{print $3}')"  # string e.g 15G
availspace="$(LC_ALL=C df -hP "${rootdir}" | tail -n 1 | awk '{print $4}')" # string e.g 5G

## LinuxGSM used space total.
rootdirdu="$(du -sh "${rootdir}" 2> /dev/null | awk '{print $1}')"
if [ -z "${rootdirdu}" ]; then
	rootdirdu="0M"
fi

## LinuxGSM used space in serverfiles dir.
serverfilesdu="$(du -sh "${serverfiles}" 2> /dev/null | awk '{print $1}')"
if [ -z "${serverfilesdu}" ]; then
	serverfilesdu="0M"
fi

## LinuxGSM used space total minus backup dir.
rootdirduexbackup="$(du -sh --exclude="${backupdir}" "${serverfiles}" 2> /dev/null | awk '{print $1}')"
if [ -z "${rootdirduexbackup}" ]; then
	rootdirduexbackup="0M"
fi

## Backup info
if [ -d "${backupdir}" ]; then
	# Used space in backups dir.
	backupdirdu="$(du -sh "${backupdir}" | awk '{print $1}')"
	# If no backup dir, size is 0M.
	if [ -z "${backupdirdu}" ]; then
		backupdirdu="0M"
	fi

	# number of backups set to 0 by default.
	backupcount=0

	# If there are backups in backup dir.
	if [ "$(find "${backupdir}" -name "*.tar.gz" | wc -l)" -ne "0" ]; then
		# number of backups.
		backupcount="$(find "${backupdir}"/*.tar.gz | wc -l)" # integer
		# most recent backup.
		lastbackup="$(ls -1t "${backupdir}"/*.tar.gz | head -1)" # string
		# date of most recent backup.
		lastbackupdate="$(date -r "${lastbackup}")" # string
		# no of days since last backup.
		lastbackupdaysago="$((($(date +'%s') - $(date -r "${lastbackup}" +'%s')) / 60 / 60 / 24))" # integer
		# size of most recent backup.
		lastbackupsize="$(du -h "${lastbackup}" | awk '{print $1}')" # string
	fi
fi

# Network Interface name
netint=$(${ipcommand} -o addr | grep "${ip}" | awk '{print $2}')                      # e.g eth0
netlink=$(${ethtoolcommand} "${netint}" 2> /dev/null | grep Speed | awk '{print $2}') # e.g 1000Mb/s

# Sets the SteamCMD glibc requirement if the game server requirement is less or not required.
if [ "${appid}" ]; then
	if [ "${glibc}" = "null" ] || [ -z "${glibc}" ] || [ "$(printf '%s\n'${glibc}'\n' "2.14" | sort -V | head -n 1)" != "2.14" ]; then
		glibc="2.14"
	fi
fi

# Gather Port Info using ss.
ssinfo="$(ss -tuplwn)"

#!/bin/bash
# LinuxGSM command_dev_parse_distro_details.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Display parsed distro details.

check_ip.sh
check_status.sh
info_distro.sh

# Create an associative array of the server details.
declare -A server_details=(
	['.NET Version']="${dotnetversion}"
	['Arch']="${arch}"
	['Backup Count']="${backupcount}"
	['Backup Last Date']="${lastbackupdate}"
	['Backup Last Days Ago']="${lastbackupdaysago}"
	['Backup Last Size']="${lastbackupsize}"
	['Backup Last']="${lastbackup}"
	['CPU Average Load']="${load}"
	['CPU Cores']="${cpucores}"
	['CPU Frequency']="${cpufreqency}"
	['CPU Model']="${cpumodel}"
	['Distro Codename']="${distrocodename}"
	['Distro ID Like']="${distroidlike}"
	['Distro ID']="${distroid}"
	['Distro Kernel']="${kernel}"
	['Distro Name']="${distroname}"
	['Distro Version CSV']="${distroversioncsv}"
	['Distro Version RH']="${distroversionrh}"
	['Distro Version']="${distroversion}"
	['Distro-Info Support']="${distrosupport}"
	['File System']="${filesystem}"
	['Game Server PID']="${gameserverpid}"
	['Gameserver CPU Used MHz']="${cpuusedmhz}"
	['Gameserver CPU Used']="${cpuused}"
	['Gameserver Mem Used MB']="${memusedmb}"
	['Gameserver Mem Used Pct']="${memusedpct}"
	['GLIBC Version']="${glibcversion}"
	['GLIBC']="${glibc}"
	['HLDS Linux PID']="${hldslinuxpid}"
	['Java Version']="${javaversion}"
	['Mono Version']="${monoversion}"
	['Network Interface']="${netint}"
	['Network Link Speed']="${netlink}"
	['Old Free']="${oldfree}"
	['Phys Mem Available']="${physmemavailable}"
	['Phys Mem Buffers KB']="${physmembufferskb}"
	['Phys Mem Cached']="${physmemcached}"
	['Phys Mem Free']="${physmemfree}"
	['Phys Mem Reclaimable KB']="${physmemreclaimablekb}"
	['Phys Mem Total GB']="${physmemtotalgb}"
	['Phys Mem Used']="${physmemused}"
	['Size Backup Dir']="${backupdirdu}"
	['Size Root Dir ']="${rootdirdu}"
	['Size Root Dir Excl. Backup']="${rootdirduexbackup}"
	['Size Serverfiles']="${serverfilesdu}"
	['SRCDS Linux PID']="${srcdslinuxpid}"
	['Storage Available']="${availspace}"
	['Storage Total']="${totalspace}"
	['Storage Used']="${usedspace}"
	['Swap Free']="${swapfree}"
	['Swap Total']="${swaptotal}"
	['Swap Used']="${swapused}"
	['Tmux Version']="${tmuxversion}"
	['Uptime Days']="${days}"
	['Uptime Hours']="${hours}"
	['Uptime Minutes']="${minutes}"
	['Uptime Total Seconds']="${uptime}"
	['Virtual Environment']="${virtualenvironment}"
	# ['Distro Info Array']="${distro_info_array}"
	# ['Distros Unsupported Array']="${distrosunsupported_array}"
	# ['Distros Unsupported']="${distrosunsupported}"
	# ['Human Readable']="${humanreadable}"
	# ['Phys Mem Actual Free KB']="${physmemactualfreekb}"
	# ['Phys Mem Cached KB']="${physmemcachedkb}"
	# ['Phys Mem Free KB']="${physmemfreekb}"
	# ['Phys Mem Total KB']="${physmemtotalkb}"
	# ['Phys Mem Total MB']="${physmemtotalmb}"
	# ['SS Info']="${ssinfo}"
)

# Initialize variables to keep track of available and missing distro details.
available_details=""
missing_details=""

# Loop through the distro details and store them.
for key in "${!server_details[@]}"; do
    value=${server_details[$key]}
	if [ -n "$value" ]; then
		available_details+="${lightblue}${key}: ${default}${value}\n"
	else
		missing_details+="${key}\n"
	fi
done

# Sort and output the available distro details.
if [ -n "$available_details" ]; then
    echo -e ""
    echo -e "${bold}${lightgreen}Available Distro Details${default}"
    fn_messages_separator
    echo -e "${available_details}" | sort
fi

# Sort and output the missing distro details.
if [ -n "$missing_details" ]; then
    echo -e ""
    echo -e "${lightgreen}Missing or unsupported Distro Details${default}"
    fn_messages_separator
    echo -e "${missing_details}" | sort
fi

core_exit.sh

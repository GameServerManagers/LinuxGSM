#!/bin/bash
# LinuxGSM command_dev_detect_glibc.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Automatically detects the version of GLIBC that is required.
# Can check a file or directory recursively.

local commandname="DETECT-GLIBC"
local commandaction="Detect-Glibc"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e "================================="
echo -e "glibc Requirements Checker"
echo -e "================================="

if [ -z "$(command -v objdump)" ]; then
	fn_print_failure_nl "objdump is missing"
	fn_script_log_fatal "objdump is missing"
	core_exit.sh
fi

if [ -z "${serverfiles}" ]; then
	dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
fi

if [ -d "${serverfiles}" ]; then
	echo -e "Checking directory: "
	echo -e "${serverfiles}"
elif [ -f "${serverfiles}" ]; then
	echo -e "Checking file: "
	echo -e "${serverfiles}"
fi
echo -e ""


local glibc_check_dir_array=( steamcmddir serverfiles )
for glibc_check_var in "${glibc_check_dir_array[@]}"
do
	if [ "${glibc_check_var}" == "serverfiles" ]; then
		glibc_check_dir="${serverfiles}"
		glibc_check_name="${gamename}"
	elif [ "${glibc_check_var}" == "steamcmddir" ]; then
		glibc_check_dir="${steamcmddir}"
		glibc_check_name="SteamCMD"
	fi

	if [ -d "${glibc_check_dir}" ]; then
		glibc_check_files=$(find "${glibc_check_dir}" | wc -l)
		find "${glibc_check_dir}" -type f -print0 |
		while IFS= read -r -d $'\0' line; do
			glibcversion=$(objdump -T "${line}" 2>/dev/null | grep -oP "GLIBC[^ ]+" | grep -v GLIBCXX | sort | uniq | sort -r --version-sort | head -n 1)
			if [ "${glibcversion}" ]; then
				echo -e "${glibcversion}: ${line}" >>"${tmpdir}/detect_glibc_files_${glibc_check_var}.tmp"
			fi
			objdump -T "${line}" 2>/dev/null | grep -oP "GLIBC[^ ]+" >>"${tmpdir}/detect_glibc_${glibc_check_var}.tmp"
			echo -n "${i} / ${glibc_check_files}" $'\r'
			((i++))
		done
			echo -e ""
			echo -e ""
			echo -e "${glibc_check_name} glibc Requirements"
			echo -e "================================="
		if [ -f "${tmpdir}/detect_glibc_files_${glibc_check_var}.tmp" ]; then
			echo -e "Required glibc"
			cat "${tmpdir}/detect_glibc_${glibc_check_var}.tmp" | sort | uniq | sort -r --version-sort | head -1 |tee -a "${tmpdir}/detect_glibc_highest.tmp"
			echo -e ""
			echo -e "Files requiring GLIBC"
			echo -e "Highest verion required: filename"
			cat "${tmpdir}/detect_glibc_files_${glibc_check_var}.tmp"
			echo -e ""
			echo -e "All required GLIBC versions"
			cat "${tmpdir}/detect_glibc_${glibc_check_var}.tmp" | sort | uniq | sort -r --version-sort
			rm "${tmpdir}/detect_glibc_${glibc_check_var}.tmp"
			rm "${tmpdir}/detect_glibc_files_${glibc_check_var}.tmp"
		else
			fn_print_information_nl "glibc is not required"
		fi
	else
		fn_print_information_nl "${glibc_check_name} is not installed"
	fi
done
echo -e ""
echo -e "Final glibc Requirement"
echo -e "================================="
if [ -f "${tmpdir}/detect_glibc_highest.tmp" ]; then
	cat "${tmpdir}/detect_glibc_highest.tmp" | sort | uniq | sort -r --version-sort | head -1
	rm "${tmpdir}/detect_glibc_highest.tmp"
else
	fn_print_information_nl "glibc is not required"
fi
core_exit.sh

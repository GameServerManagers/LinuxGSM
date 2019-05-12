#!/bin/bash
# LinuxGSM install_waterfall.sh function
# Author: Duval Lucas
# Website: https://linuxgsm.com
# Description: Gets user to select the version of Waterfall.

# Bash Menu
fn_install_menu_bash_waterfall() {
	local resultvar=$1
	title=$2
	caption=$3
	options=$4
	fn_print_horizontal
	fn_print_center "${title}"
	fn_print_center "${caption}"
	fn_print_horizontal
	menu_options=()
	while read -r line; do
		if [ -n "${line}" ];then
			version=${line:1:-1}
			menu_options+=( "${version}" )
		fi
	done <<<  ${options}
	menu_options+=( "Cancel" )
	select option in "${menu_options[@]}"; do
		if [ -n "${option}" ]&&[ "${option}" != "Cancel" ]; then
			eval "$resultvar=\"${option/%\ */}\""
		fi
		break
	done
}

# Whiptail/Dialog Menu
fn_install_menu_whiptail_waterfall() {
	local menucmd=$1
	local resultvar=$2
	title=$3
	caption=$4
	options=$5
	height=${6:-40}
	width=${7:-80}
	menuheight=${8:-30}
	menu_options=()
	while read -r line; do
		if [ -n "${line}" ];then
			version=${line:1:-1}
			menu_options+=( ${version//\"} "Version ${version//\"}" )
		fi
	done <<< "${options}"
	OPTION=$(${menucmd} --title "${title}" --menu "${caption}" "${height}" "${width}" "${menuheight}" "${menu_options[@]}" 3>&1 1>&2 2>&3)
	if [ $? == 0 ]; then
		eval "$resultvar=\"${OPTION}\""
	else
		eval "$resultvar="
	fi
}

# Menu selector
fn_install_menu_waterfall() {
	local resultvar=$1
	local selection=""
	title=$2
	caption=$3
	options=$4
	# Get menu command
	for menucmd in whiptail dialog bash; do
		if [ -x "$(command -v "${menucmd}")" ]; then
			menucmd=$(command -v "${menucmd}")
			break
		fi
	done
	case "$(basename "${menucmd}")" in
		whiptail|dialog)
			fn_install_menu_whiptail_waterfall "${menucmd}" selection "${title}" "${caption}" "${options}" 40 80 30;;
		*)
			fn_install_menu_bash_waterfall selection "${title}" "${caption}" "${options}";;
	esac
	eval "$resultvar=\"${selection}\""
}

# Get all version available for Waterfall
remotebuild=$(${curlpath} -s "https://papermc.io/api/v1/waterfall" | jq -r '.versions')

# Remove square bracket
remotebuild=${remotebuild:1:-1}
fn_install_menu_waterfall waterfall_version "LinuxGSM" "Select Waterfall version to install" "${remotebuild}"
echo "${waterfall_version}" > "${configdirserver}/waterfall_version.cfg"
fn_print_info_nl "Selected version: ${waterfall_version}"

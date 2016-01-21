#!/bin/bash
# LGSM fn_messages function
# Author: Jared Ballou
# Website: http://gameservermanagers.com
lgsm_version="200116"

# Description: Display menus and return selection

# Display simple Bash menu
fn_menu_bash() {
	local resultvar=$1
	title=$2
	caption=$3
	options=$4
	fn_print_horizontal
	fn_print_center $title
	fn_print_center $caption
	fn_print_horizontal
	menu_options=()
	while IFS='' read -r line || [[ -n "$line" ]]; do
		menu_options+=( "${line}" )
	done < $options
	menu_options+=( "Cancel" )
	select option in "${menu_options[@]}"; do
		if [ -n "${option}" ] && [ "${option}" != "Cancel" ]; then
			eval "$resultvar=\"${option/%\ */}\""
		fi
		break
	done
}

# Draw menu using Whiptail
fn_menu_whiptail() {
	local menucmd=$1
	local resultvar=$2
	title=$3
	caption=$4
	options=$5
	height=${6:-40}
	width=${7:-80}
	menuheight=${8:-30}
	#whiptail --title "<menu title>" --menu "<text to show>" <height> <width> <menu height> [ <tag> <item> ] . . .
	menu_options=()
	while read -r key val; do
		menu_options+=( ${key//\"} "${val//\"}" )
	done < $options
	OPTION=$($menucmd --title "${title}" --menu "${caption}" $height $width $menuheight "${menu_options[@]}" 3>&1 1>&2 2>&3)
	if [ $? = 0 ]; then
		eval "$resultvar=\"${OPTION}\""
	else
		eval "$resultvar="
	fi
}

# Show menu and receive input. We try to see if whiptail/dialog is available
# for a pretty ncurses menu. If not, use Bash builtins.
fn_menu() {
	local resultvar=$1
	local selection=""
	title=$2
	caption=$3
	options=$4
	# If this is a list of options as a string, dump it to a file so we can process it
	if [ ! -e $options ]; then
		echo -ne "{$options}\n" > "${cachedir}/menu.options"
		options="${cachedir}/menu.options"
	fi

	# Get menu command
	for menucmd in whiptail dialog bash; do
		if [ -x $(which $menucmd) ]; then
			menucmd=$(which $menucmd)
			break
		fi
	done
	case "$(basename $menucmd)" in
		whiptail|dialog)
			fn_menu_whiptail "${menucmd}" selection "${title}" "${caption}" "${options}" 40 80 30
			;;
		*)
			fn_menu_bash selection "${title}" "${caption}" "${options}"
			;;
	esac
	eval "$resultvar=\"${selection}\""
}

# Example usage:
# This will display a menu of available games to install
#fn_menu result "Linux Game Server Manager" "Select game to install" "../gamedata/__game_list"
#echo "result is ${result}"

#!/bin/bash
# LGSM game_settings.sh function
# Author: Jared Ballou
# Website: http://gameservermanagers.com
lgsm_version="180116"

function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"
local modulename="Settings"

# Config files
cfg_file_default="${scriptcfgdir}/_default.cfg"
cfg_file_common="${scriptcfgdir}/_common.cfg"
cfg_file_instance="${scriptcfgdir}/${servicename}.cfg"

# Config file headers
cfg_header_all="# Your settings for all servers go in _common.cfg\n# Server-specific settings go into \$SERVER.cfg"
cfg_header_default="# Default config - Changes will be overwritten by updates.\n${cfg_header_all}"
cfg_header_common="# Common config - Will not be overwritten by script.\n${cfg_header_all}"
cfg_header_instance="# Instance Config for ${servicename} - Will not be overwritten by script.\n${cfg_header_all}"


# If default config does not exist, create it. This should come from Git, and will be overwritten by updates.
# Rather than try to wget it from Github or other fancy ways to get it, the simplest way to ensure it works is to simply create it here.
fn_update_config()
{
	key=$1
	val=$2
	cfg_file=${3:-$cfg_file_default}
	comment=${4:-""}

	# Get current key/value pair from file
	exists=$(grep "^${key}=" $cfg_file 2>/dev/null)
	exists_comment=$(echo $(echo $exists | cut -d'#' -f2-))
	case "${val}" in
		""|"--UNSET--")
			if [ "${exists}" != "" ]; then
				echo "Removing ${key} from ${cfg_file}"
				sed "/${key}=.*/d" -i $cfg_file
			fi
			return
			;;
		"--EMPTY--")
			val=""
			;;
	esac
	# Put " # " at beginning of comment if not empty
	if [ "${comment}" != "" ]
	then
		comment=" # ${comment}"
	else
		if [ "${exists_comment}" != "" ]; then
			comment=" # ${exists_comment}"
		fi
	fi

	# Line to be put in
	data="${key}=\"${val}\"${comment}"

	# Check if key exists in config
	if [ "${exists}" != "" ]; then
		# If the line isn't the same as the parsed data line, replace it
		if [ "${exists}" != "${data}" ]; then
			#echo "Updating ${data} in ${cfg_file}"
			sed -e "s%^${key}=.*\$%${data}%g" -i $cfg_file
			#sed "/${key}=.*/${data}/" -i $cfg_file
		fi
	else
		# If value does not exist, append to file
		#echo "Adding ${data} to ${cfg_file}"
		echo -ne "${data}\n" >> $cfg_file
	fi
}

fn_create_config(){
	cfg_type=${1:-default}
	cfg_force=$2
	cfg_file="cfg_file_${cfg_type}"
	cfg_header="cfg_header_${cfg_type}"
	
	cfg_dir=$(dirname ${!cfg_file})
	#If config directory does not exist, create it
	if [ ! -e $cfg_dir ]; then mkdir -p $cfg_dir; fi

	# Create file header if needed
	if [ ! -e ${!cfg_file} ] || [ "${cfg_force}" != "" ]; then
		echo "Creating ${cfg_type} config at ${!cfg_file}"
		echo -ne "${!cfg_header}\n\n" > ${!cfg_file}
		# Dump in defaults for this game
		if [ "${cfg_type}" == "default" ]; then
			cat ${settingsdir}/settings >> ${!cfg_file}
		fi
	fi
}

fn_flush_game_settings(){
	if [ -e $settingsdir ]; then
		rm -rf $settingsdir > /dev/null
	fi
	mkdir -p $settingsdir
}

fn_import_game_settings(){
	import="${gamedatadir}/${1}"
	importdir=$(echo "${gamedatadir}" | sed -e "s|${lgsmdir}/||g")
	#echo $importdir
	if [ ! -e $import ]; then
		fn_getgithubfile "${importdir}/${1}" run "gamedata/${1}"
	fi
	source $import
}

fn_set_game_params(){
	param_set=$1
	param_name=$2
	param_value=$3
	param_comment=$4
	fn_update_config "${param_name}" "${param_value}" "${settingsdir}/${param_set}" "${param_comment}"
}


fn_get_game_params(){
	param_set=$1
	param_name=$2
	param_default=$3
}

# Flush old setings buffer
fn_flush_game_settings

# Import this game's settings
fn_import_game_settings $selfname

# New method is to always run this function, it will overwrite defaults with whatever the new script values are
cfg_version_default=$(grep '^lgsm_version="' "${cfg_file_default}" 2>&1 | cut -d'"' -f2)
if [ "${cfg_version_default}" != "${version}" ]; then
	fn_create_config default 1
fi

# Load defaults
source $cfg_file_default

# Load sitewide common settings (so that Git updates can safely overwrite default.cfg)
if [ ! -f $cfg_file_common ]; then fn_create_config common; else source $cfg_file_common; fi

# Load instance specific settings
if [ ! -f $cfg_file_instance ]; then fn_create_config instance; else source $cfg_file_instance; fi

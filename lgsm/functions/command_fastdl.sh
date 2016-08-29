#!/bin/bash
# LGSM command_fastdl.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Creates a FastDL folder.

local commandname="FASTDL"
local commandaction="FastDL"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh

# Directories
webdir="${rootdir}/public_html"
fastdldir="${webdir}/fastdl"
addonsdir="${systemdir}/addons"
# Server lua autorun dir, used to autorun lua on client connect to the server
luasvautorundir="${systemdir}/lua/autorun/server"
luafastdlfile="lgsm_cl_force_fastdl.lua"
luafastdlfullpath="${luasvautorundir}/${luafastdlfile}"

fn_check_bzip2(){
	# Returns true if not installed
	if [ -z "$(command -v bzip2)" ]; then
		bzip2installed="0"
		fn_print_info "bzip2 is not installed !"
		fn_script_log_info "bzip2 is not installed"
		echo -en "\n"
		sleep 1
		echo "We advise using it"
		echo "For more information, see https://github.com/GameServerManagers/LinuxGSM/wiki/FastDL#bzip2-compression"
		sleep 2
	else
		bzip2installed="1"
	fi
}

fn_fastdl_init(){
	# User confirmation
	fn_print_ok "Welcome to LGSM's FastDL generator"
	sleep 1
	echo -en "\n"
	fn_script_log "Started FastDL creation"
	while true; do
		read -e -i "y" -p "Continue? [Y/n]" yn
		case $yn in
		[Yy]* ) break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
		esac
	done
	fn_script_log "Initiating FastDL creation"

	# Check and create folders
	if [ ! -d "${webdir}" ]; then
		echo ""
		fn_print_info "Creating FastDL directories"
		echo -en "\n"
		sleep 1
		fn_print_dots "Creating ${webdir} directory"
		sleep 0.5
		mkdir "${webdir}"
		fn_print_ok "Created ${webdir} directory"
		fn_script_log "FastDL created ${webdir} directory"
		sleep 1
		echo -en "\n"
	fi
	if [ ! -d "${fastdldir}" ]; then
		# No folder, won't ask for removing old ones
		newfastdl=1
		fn_print_dots "Creating fastdl directory"
		sleep 0.5
		mkdir "${fastdldir}"
		fn_print_ok "Created fastdl directory"
		fn_script_log "FastDL created fastdl directory"
		sleep 1
		echo -en "\n"
		clearoldfastdl="off" # Nothing to clear
	elif  [ "$(ls -A "${fastdldir}")" ]; then
		newfastdl=0
	fi
}

fn_fastdl_config(){
	# Global settings for FastDL creation
	fn_print_info "Entering configuration"
	fn_script_log "Configuration"
	sleep 2
	echo -en "\n"
	# Prompt for clearing old files if folder was already here
	if [ -n "${newfastdl}" ] && [ "${newfastdl}" == "0" ]; then
		fn_print_dots
		while true; do
			read -e -i "y" -p "Clear old FastDL files? [Y/n]" yn
			case $yn in
			[Yy]* ) clearoldfastdl="on"; fn_script_log "clearoldfastdl enabled"; fn_print_ok "Clearing Enabled"; break;;
			[Nn]* ) clearoldfastdl="off"; fn_script_log "clearoldfastdl disabled"; fn_print_ok "Clearing Disabled"; break;;
			* ) echo "Please answer yes or no.";;
			esac
		done
		echo -en "\n"
	fi
	# Prompt for using bzip2 if it's installed
	if [ ${bzip2installed} == 1 ]; then
		fn_print_dots
		while true; do
			read -e -i "y" -p "Enable file compression using bzip2? [Y/n]" yn
			case $yn in
			[Yy]* ) bzip2enable="on"; fn_script_log "bzip2 enabled"; fn_print_ok "bzip2 Enabled"; break;;
			[Nn]* ) bzip2enable="off"; fn_script_log "bzip2 disabled"; fn_print_ok "bzip2 Disabled"; break;;
			* ) echo "Please answer yes or no.";;
			esac
		done
		echo -en "\n"
	fi
}

fn_fastdl_gmod_config(){
	# Prompt for download enforcer, that is using a .lua addfile resource generator
	fn_print_dots
	while true; do
		read -e -i "y" -p "Use client download enforcer? [Y/n]" yn
		case $yn in
		[Yy]* ) luaressource="on"; fn_script_log "DL enforcer Enabled"; fn_print_ok "Enforcer Enabled"; break;;
		[Nn]* ) luaressource="off"; fn_script_log "DL enforcer Disabled"; fn_print_ok "Enforcer Disabled"; break;;
		* ) echo "Please answer yes or no.";;
		esac
	done
	echo -en "\n"
}

fn_clear_old_fastdl(){
	# Clearing old FastDL if user answered yes
	if [ "${clearoldfastdl}" == "on" ]; then
		fn_print_info "Clearing existing FastDL folder"
		fn_script_log "Clearing existing FastDL folder"
		sleep 0.5
		rm -R "${fastdldir:?}"/*
		fn_print_ok "Old FastDL folder cleared"
		fn_script_log "Old FastDL folder cleared"
		sleep 1
		echo -en "\n"
	fi
}

fn_gmod_fastdl(){
	# Copy all needed files for FastDL
	echo ""
	fn_print_dots "Starting gathering all needed files"
	fn_script_log "Starting gathering all needed files"
	sleep 1
	echo -en "\n"

	# No choice to cd to the directory, as find can't then display relative folder
	cd "${systemdir}"

	# Map Files
	fn_print_dots "Copying map files..."
	fn_script_log "Copying map files"
	sleep 0.5
	find . -name '*.bsp' | cpio --quiet -updm "${fastdldir}"
	fn_print_ok "Map files copied"
	sleep 0.5
	echo -en "\n"

	# Materials
	fn_print_dots "Copying materials..."
	fn_script_log "Copying materials"
	sleep 0.5
	find . -name '*.vtf' | cpio --quiet -updm "${fastdldir}"
	find . -name '*.vmt' | cpio --quiet -updm "${fastdldir}"
	fn_print_ok "Materials copied"
	sleep 0.5
	echo -en "\n"

	# Models
	fn_print_dots "Copying models..."
	fn_script_log "Copying models"
	sleep 1
	find . -name '*.vtx' | cpio --quiet -updm "${fastdldir}"
	find . -name '*.vvd' | cpio --quiet -updm "${fastdldir}"
	find . -name '*.mdl' | cpio --quiet -updm "${fastdldir}"
	find . -name '*.phy' | cpio --quiet -updm "${fastdldir}"
	fn_print_ok "Models copied"
	sleep 0.5
	echo -en "\n"

	# Particles
	fn_print_dots "Copying particles..."
	fn_script_log "Copying particles"
	sleep 0.5
	find . -name '*.pcf' | cpio --quiet -updm "${fastdldir}"
	fn_print_ok "Particles copied"
	sleep 0.5
	echo -en "\n"

	# Sounds
	fn_print_dots "Copying sounds..."
	fn_script_log "Copying sounds"
	sleep 0.5
	find . -name '*.wav' | cpio --quiet -updm "${fastdldir}"
	find . -name '*.mp3' | cpio --quiet -updm "${fastdldir}"
	find . -name '*.ogg' | cpio --quiet -updm "${fastdldir}"
	fn_print_ok "Sounds copied"
	sleep 0.5
	echo -en "\n"

	# Resources (mostly fonts)
	fn_print_dots "Copying fonts and png..."
	fn_script_log "Copying fonts and png"
	sleep 1
	find . -name '*.otf' | cpio --quiet -updm "${fastdldir}"
	find . -name '*.ttf' | cpio --quiet -updm "${fastdldir}"
	find . -name '*.png' | cpio --quiet -updm "${fastdldir}"
	fn_print_ok "Fonts and png copied"
	sleep 0.5
	echo -en "\n"

	# Going back to rootdir in order to prevent mistakes
	cd "${rootdir}"

	# Correct addons folder structure for FastDL
	if [ -d "${fastdldir}/addons" ]; then
		fn_print_info "Adjusting addons' file structure"
		fn_script_log "Adjusting addon's file structure"
		sleep 1
		cp -Rf "${fastdldir}"/addons/*/* "${fastdldir}"
	#Don't remove yet	rm -R "${fastdldir:?}/addons"
		fn_print_ok "Adjusted addon's file structure"
		sleep 1
		echo -en "\n"
	fi

	# Correct content that may be into a lua folder by mistake like some darkrpmodification addons
	if [ -d "${fastdldir}/lua" ]; then
		fn_print_dots "Typical DarkRP shit detected, fixing"
		sleep 2
		cp -Rf "${fastdldir}/lua/"* "${fastdldir}"
		fn_print_ok "Stupid DarkRP file structure fixed"
		sleep 2
		echo -en "\n"
	fi
}

# Generate lua file that will force download any file into the FastDL folder
fn_lua_fastdl(){
	# Remove lua file if luaressource is turned off and file exists
	echo ""
	if [ "${luaressource}" == "off" ]; then
		if [ -f "${luafastdlfullpath}" ]; then
			fn_print_dots "Removing download enforcer"
			sleep 1
			rm -R "${luafastdlfullpath:?}"
			fn_print_ok "Removed download enforcer"
			fn_script_log "Removed old download inforcer"
			echo -en "\n"
			sleep 2
		fi
	fi
	# Remove old lua file and generate a new one if user said yes
	if [ "${luaressource}" == "on" ]; then
		if [ -f "${luafastdlfullpath}" ]; then
			fn_print_dots "Removing old download enforcer"
			sleep 1
			rm "${luafastdlfullpath}"
			fn_print_ok "Removed old download enforcer"
			fn_script_log "Removed old download enforcer"
			echo -en "\n"
			sleep 1
		fi
		fn_print_dots "Generating new download enforcer"
		fn_script_log "Generating new download enforcer"
		sleep 1
		# Read all filenames and put them into a lua file at the right path
		find "${fastdldir}" \( -type f ! -name "*.bz2" \) -printf '%P\n' | while read line; do
			echo "resource.AddFile( "\""${line}"\"" )" >> ${luafastdlfullpath}
		done
		fn_print_ok "Download enforcer generated"
		fn_script_log "Download enforcer generated"
		echo -en "\n"
		echo ""
		sleep 2
	fi
}

fn_fastdl_bzip2(){
	# Compressing using bzip2 if user said yes
	echo ""
	if [ ${bzip2enable} == "on" ]; then
		fn_print_info "Have a break, this step could take a while..."
		echo -en "\n"
		echo ""
		fn_print_dots "Compressing files using bzip2..."
		fn_script_log "Compressing files using bzip2..."
		# bzip2 all files that are not already compressed (keeping original files)
		find "${fastdldir}" \( -type f ! -name "*.bz2" \) -exec bzip2 -qk \{\} \;
		fn_print_ok "bzip2 compression done"
		fn_script_log "bzip2 compression done"
		sleep 1
		echo -en "\n"
	fi
}

fn_fastdl_completed(){
	# Finished message
	echo ""
	fn_print_ok "Congratulations, it's done!"
	fn_script_log "FastDL job done"
	sleep 2
	echo -en "\n"
	echo ""
	fn_print_info "Need more documentation? See https://github.com/GameServerManagers/LinuxGSM/wiki/FastDL"
	echo -en "\n"
	if [ "$bzip2installed" == "0" ]; then
	echo "By the way, you'd better install bzip2 and re-run this command!"
	fi
	echo "Credits : UltimateByte"
}

# Game checking and functions running
# Garry's Mod
if [ "${gamename}" == "Garry's Mod" ]; then
	fn_check_bzip2
	fn_fastdl_init
	fn_fastdl_config
	fn_fastdl_gmod_config
	fn_clear_old_fastdl
	fn_gmod_fastdl
	fn_lua_fastdl
	fn_fastdl_bzip2
	fn_fastdl_completed
	exit
fi

#!/bin/bash
# LGSM command_fastdl function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: http://gameservermanagers.com
lgsm_version="210216"

# Description: Creates a FastDL folder

local modulename="FastDL"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh

# Directories
webdir="${rootdir}/www"
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
	fn_printinfo "bzip2 is not installed !"
	fn_scriptlog "bzip2 is not installed"
	echo -en "\n"
	sleep 1
	echo "We advise using it"
	echo "For more information, see https://github.com/dgibbs64/linuxgsm/wiki/FastDL#bzip2-compression"
	sleep 2
else
	bzip2installed="1"
fi
}

fn_fastdl_init(){
# User confirmation
fn_printok "Welcome to LGSM's FastDL generator"
sleep 1
echo -en "\n"
fn_scriptlog "Started FastDL creation"
while true; do
	read -e -i "y" -p "Continue? [Y/n]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) exit;;
	* ) echo "Please answer yes or no.";;
	esac
done
fn_scriptlog "Initiating FastDL creation"

# Check and create folders
if [ ! -d "${webdir}" ]; then
	echo ""
	fn_printinfo "Creating FastDL directories"
	echo -en "\n"
	sleep 1
	fn_printdots "Creating www directory"
	sleep 0.5
	mkdir "${webdir}"
	fn_printok "Created www directory"
	fn_scriptlog "FastDL created www directory"
	sleep 1
	echo -en "\n"
fi
if [ ! -d "${fastdldir}" ]; then
	# No folder, won't ask for removing old ones
	newfastdl=1
	fn_printdots "Creating fastdl directory"
	sleep 0.5
	mkdir "${fastdldir}"
	fn_printok "Created fastdl directory"
	fn_scriptlog "FastDL created fastdl directory"
	sleep 1
	echo -en "\n"
	clearoldfastdl="off" # Nothing to clear
elif  [ "$(ls -A "${fastdldir}")" ]; then
	newfastdl=0
fi
}

fn_fastdl_config(){
# Global settings for FastDL creation
fn_printinfo "Entering configuration"
fn_scriptlog "Configuration"
sleep 2
echo -en "\n"
# Prompt for clearing old files if folder was already here
if [ -n "${newfastdl}" ] && [ "${newfastdl}" == "0" ]; then
	fn_printdots
	while true; do
		read -e -i "y" -p "Clear old FastDL files? [Y/n]" yn
		case $yn in
		[Yy]* ) clearoldfastdl="on"; fn_scriptlog "clearoldfastdl enabled"; fn_printok "Clearing Enabled"; break;;
		[Nn]* ) clearoldfastdl="off"; fn_scriptlog "clearoldfastdl disabled"; fn_printok "Clearing Disabled"; break;;
		* ) echo "Please answer yes or no.";;
		esac
	done
	echo -en "\n"
fi
# Prompt for using bzip2 if it's installed
if [ ${bzip2installed} == 1 ]; then
	fn_printdots
	while true; do
		read -e -i "y" -p "Enable file compression using bzip2? [Y/n]" yn
		case $yn in
		[Yy]* ) bzip2enable="on"; fn_scriptlog "bzip2 enabled"; fn_printok "bzip2 Enabled"; break;;
		[Nn]* ) bzip2enable="off"; fn_scriptlog "bzip2 disabled"; fn_printok "bzip2 Disabled"; break;;
		* ) echo "Please answer yes or no.";;
		esac
	done
	echo -en "\n"
fi
}

fn_fastdl_gmod_config(){
# Prompt for download enforcer, that is using a .lua addfile resource generator
fn_printdots
while true; do
	read -e -i "y" -p "Use client download enforcer? [Y/n]" yn
	case $yn in
	[Yy]* ) luaressource="on"; fn_scriptlog "DL enforcer Enabled"; fn_printok "Enforcer Enabled"; break;;
	[Nn]* ) luaressource="off"; fn_scriptlog "DL enforcer Disabled"; fn_printok "Enforcer Disabled"; break;;
	* ) echo "Please answer yes or no.";;
	esac
done
echo -en "\n"
}

fn_clear_old_fastdl(){
# Clearing old FastDL if user answered yes
if [ "${clearoldfastdl}" == "on" ]; then
	fn_printinfo "Clearing existing FastDL folder"
	fn_scriptlog "Clearing existing FastDL folder"
	sleep 0.5
	rm -R "${fastdldir:?}"/*
	fn_printok "Old FastDL folder cleared"
	fn_scriptlog "Old FastDL folder cleared"
	sleep 1
	echo -en "\n"
fi
}

fn_gmod_fastdl(){
# Copy all needed files for FastDL
echo ""
fn_printdots "Starting gathering all needed files"
fn_scriptlog "Starting gathering all needed files"
sleep 1
echo -en "\n"

# No choice to cd to the directory, as find can't then display relative folder
cd "${systemdir}"

# Map Files
fn_printdots "Copying map files..."
fn_scriptlog "Copying map files"
sleep 0.5
find . -name '*.bsp' | cpio --quiet -updm "${fastdldir}"
fn_printok "Map files copied"
sleep 0.5
echo -en "\n"

# Materials
fn_printdots "Copying materials..."
fn_scriptlog "Copying materials"
sleep 0.5
find . -name '*.vtf' | cpio --quiet -updm "${fastdldir}"
find . -name '*.vmt' | cpio --quiet -updm "${fastdldir}"
fn_printok "Materials copied"
sleep 0.5
echo -en "\n"

# Models
fn_printdots "Copying models..."
fn_scriptlog "Copying models"
sleep 1
find . -name '*.vtx' | cpio --quiet -updm "${fastdldir}"
find . -name '*.vvd' | cpio --quiet -updm "${fastdldir}"
find . -name '*.mdl' | cpio --quiet -updm "${fastdldir}"
find . -name '*.phy' | cpio --quiet -updm "${fastdldir}"
fn_printok "Models copied"
sleep 0.5
echo -en "\n"

# Particles
fn_printdots "Copying particles..."
fn_scriptlog "Copying particles"
sleep 0.5
find . -name '*.pcf' | cpio --quiet -updm "${fastdldir}"
fn_printok "Particles copied"
sleep 0.5
echo -en "\n"

# Sounds
fn_printdots "Copying sounds..."
fn_scriptlog "Copying sounds"
sleep 0.5
find . -name '*.wav' | cpio --quiet -updm "${fastdldir}"
find . -name '*.mp3' | cpio --quiet -updm "${fastdldir}"
find . -name '*.ogg' | cpio --quiet -updm "${fastdldir}"
fn_printok "Sounds copied"
sleep 0.5
echo -en "\n"

# Resources (mostly fonts)
fn_printdots "Copying fonts and png..."
fn_scriptlog "Copying fonts and png"
sleep 1
find . -name '*.otf' | cpio --quiet -updm "${fastdldir}"
find . -name '*.ttf' | cpio --quiet -updm "${fastdldir}"
find . -name '*.png' | cpio --quiet -updm "${fastdldir}"
fn_printok "Fonts and png copied"
sleep 0.5
echo -en "\n"

# Going back to rootdir in order to prevent mistakes
cd "${rootdir}"

# Correct addons folder structure for FastDL
if [ -d "${fastdldir}/addons" ]; then
	fn_printinfo "Adjusting addons' file structure"
	fn_scriptlog "Adjusting addon's file structure"
	sleep 1
	cp -Rf "${fastdldir}"/addons/*/* "${fastdldir}"
#Don't remove yet	rm -R "${fastdldir:?}/addons"
	fn_printok "Adjusted addon's file structure"
	sleep 1
	echo -en "\n"
fi

# Correct content that may be into a lua folder by mistake like some darkrpmodification addons
if [ -d "${fastdldir}/lua" ]; then
	fn_printdots "Typical DarkRP shit detected, fixing"
	sleep 2
	cp -Rf "${fastdldir}/lua/"* "${fastdldir}"
	fn_printok "Stupid DarkRP file structure fixed"
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
		fn_printdots "Removing download enforcer"
		sleep 1
		rm -R "${luafastdlfullpath:?}"
		fn_printok "Removed download enforcer"
		fn_scriptlog "Removed old download inforcer"
		echo -en "\n"
		sleep 2
	fi
fi
# Remove old lua file and generate a new one if user said yes
if [ "${luaressource}" == "on" ]; then
	if [ -f "${luafastdlfullpath}" ]; then
		fn_printdots "Removing old download enforcer"
		sleep 1
		rm "${luafastdlfullpath}"
		fn_printok "Removed old download enforcer"
		fn_scriptlog "Removed old download enforcer"
		echo -en "\n"
		sleep 1
	fi
	fn_printdots "Generating new download enforcer"
	fn_scriptlog "Generating new download enforcer"
	sleep 1
	# Read all filenames and put them into a lua file at the right path
	find "${fastdldir}" \( -type f ! -name "*.bz2" \) -printf '%P\n' | while read line; do
		echo "resource.AddFile( "\""${line}"\"" )" >> ${luafastdlfullpath}
	done
	fn_printok "Download enforcer generated"
	fn_scriptlog "Download enforcer generated"
	echo -en "\n"
	echo ""
	sleep 2
fi
}

fn_fastdl_bzip2(){
# Compressing using bzip2 if user said yes
echo ""
if [ ${bzip2enable} == "on" ]; then
	fn_printinfo "Have a break, this step could take a while..."
	echo -en "\n"
	echo ""
	fn_printdots "Compressing files using bzip2..."
	fn_scriptlog "Compressing files using bzip2..."
	# bzip2 all files that are not already compressed (keeping original files)
	find "${fastdldir}" \( -type f ! -name "*.bz2" \) -exec bzip2 -qk \{\} \;
	fn_printok "bzip2 compression done"
	fn_scriptlog "bzip2 compression done"
	sleep 1
	echo -en "\n"
fi
}

fn_fastdl_completed(){
# Finished message
echo ""
fn_printok "Congratulations, it's done !"
fn_scriptlog "FastDL job done"
sleep 2
echo -en "\n"
echo ""
fn_printinfo "Need more doc ? See https://github.com/dgibbs64/linuxgsm/wiki/FastDL"
echo -en "\n"
if [ "$bzip2installed" == "0" ]; then
echo "By the way, you'd better install bzip2 an re-run this command !"
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

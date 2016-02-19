#!/bin/bash
# LGSM command_fastdl function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: http://gameservermanagers.com
lgsm_version="190216"

# Description: Creates a FastDL folder

local modulename="FastDL"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh

# Directories
webdir="${rootdir}/www"
fastdldir="${webdir}/fastdl"
addonsdir="${systemdir}/addons"
# Server lua autorun dir, used to autorun lua on client connect to the server
luasvautorundir="${systemdir}/lua/audoturn/server"
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
	echo "For more information, see https://github.com/dgibbs64/linuxgsm/wiki/Fastdl#bzip2-compression"
	sleep 2
else
	bzip2installed="1"
fi
}

fn_fastdl_init(){
# User confirmation
fn_printok "Welcome to LGSM's FastDL generator"
echo -en "\n"
fn_scriptlog "Started FastDL creation"
sleep 1
while true; do
	read -p "Continue? [y/N]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) exit;;
	* ) echo "Please answer yes or no.";;
	esac
done
fn_scriptlog "Initiating FastDL creation"

# Check and create folders
if [ ! -d "${webdir}" ]; then
	fn_printdots  "Creating www directory..."
	sleep 0.5
	mkdir "${webdir}"
	sleep 1
	fn_scriptlog "FastDL created ${webdir}"
fi
if [ ! -d "${fastdldir}" ]; then
	# No folder, won't ask for removing old ones
	newfastdl=1
	fn_printdots "Creating FastDL directory..."
	sleep 0.5
	mkdir "${fastdldir}"
	sleep 1
	fn_scriptlog "FastDL created ${fastdldir}"
	fn_printok "Folders created"
	echo -en "\n"
else
	# Used to prompt for removing old files
	newfastdl=0
fi
}

fn_fastdl_config(){
# Global settings for FastDL creation
fn_printinfo "Entering configuration"
fn_scriptlog "Configuration"
echo -en "\n"
sleep 2
# Prompt for clearing old files if folder was already here
if [ ${newfastdl} == 0 ]; then
	fn_printdots
	while true; do
		read -p "Clear old FastDL files? [y/N]" yN
		case $yn in
		[Yy]* ) clearoldfastdl="on"; fn_scriptlog "clearoldfastdl enabled"; fn_printok "Clearing Enabled"; break;;
		[Nn]* ) clearoldfastdl="off"; fn_scriptlog "clearoldfastdl disabled"; fn_printok "Clearing Disabled"; break;;
		* ) echo "Please answer yes or no.";;
		esac
	done
	sleep 1
	echo -en "\n"
fi
# Prompt for using bzip2 if it's installed
if [ ${bzip2installed} == 1 ]; then
	fn_printdots
	while true; do
		read -p "Enable file compression using bzip2? [Y/n]" Yn
		case $yn in
		[Yy]* ) bzip2enable="on"; fn_scriptlog "bzip2 enabled"; fn_printok "bzip2 Enabled"; break;;
		[Nn]* ) bzip2enable="off"; fn_scriptlog "bzip2 disabled"; fn_printok "bzip2 Disabled;" break;;
		* ) echo "Please answer yes or no.";;
		esac
	done
	sleep 1
	echo -en "\n"
fi
}

fn_fastdl_gmod_config(){
# Prompt for download enforcer, that is using a .lua addfile resource generator
fn_printdots
while true; do
	read -p "Use client download enforcer? [Y/n]" Yn
	case $yn in
	[Yy]* ) luaressource="on"; fn_scriptlog "DL enforcer Enabled"; fn_printok "Enforcer Enabled"; break;;
	[Nn]* ) luaressource="off"; "DL enforcer Disabled"; fn_printok "Enforcer Disabled"; break;;
	* ) echo "Please answer yes or no.";;
	esac
	sleep1
	echo -en "\n"
done
}

fn_clear_old_fastdl(){
# Clearing old FastDL if user answered yes
if [ ${clearoldfastdl} == "on" ]; then
	fn_printinfo "Clearing existing FastDL folder"
	fn_scriptlog "Clearing existing FastDL folder"
	sleep 1
	rm -R "${fastdldir}"/*
	fn_printok "Old FastDL folder cleared"
	fn_scriptlog "Old FastDL folder cleared"
	echo -en "\n"
fi
}

fn_gmod_fastdl(){
# Copy all needed files for fastDL
fn_printdots "Gathering all needed files..."
echo -en "\n"
sleep 1

# Map Files
fn_printdots "Copying map files..."
fn_scriptlog "Copying map files"
sleep 1
find "${addonsdir}" -name '*.bsp' | cpio --quiet -updm "${fastdldir}"
fn_printok "Map files copied"
echo -en "\n"
sleep 1

# Materials
fn_printdots "Copying materials..."
fn_scriptlog "Copying materials"
sleep 1
find "${addonsdir}" -name '*.vtf' | cpio --quiet -updm "${fastdldir}"
find "${addonsdir}" -name '*.vmt' | cpio --quiet -updm "${fastdldir}"
fn_printok "Materials copied"
echo -en "\n"
sleep 1

# Models
fn_printdots "Copying models..."
fn_scriptlog "Copying models"
sleep 1
find "${addonsdir}" -name '*.vtx' | cpio --quiet -updm "${fastdldir}"
find "${addonsdir}" -name '*.vvd' | cpio --quiet -updm "${fastdldir}"
find "${addonsdir}" -name '*.mdl' | cpio --quiet -updm "${fastdldir}"
find "${addonsdir}" -name '*.phy' | cpio --quiet -updm "${fastdldir}"
fn_printok "Models copied"
echo -en "\n"
sleep 1

# Particles
fn_printdots "Copying particles..."
fn_scriptlog "Copying particles"
sleep 1
find "${addonsdir}" -name '*.pcf' | cpio --quiet -updm "${fastdldir}"
fn_printok "Particles copied"
echo -en "\n"
sleep 1

# Sounds
fn_printdots "Copying sounds..."
fn_scriptlog "Copying sounds"
sleep 1
find "${addonsdir}" -name '*.wav' | cpio --quiet -updm "${fastdldir}"
find "${addonsdir}" -name '*.mp3' | cpio --quiet -updm "${fastdldir}"
find "${addonsdir}" -name '*.ogg' | cpio --quiet -updm "${fastdldir}"
fn_printok "Sounds copied"
echo -en "\n"
sleep 1

# Resources (mostly fonts)
fn_printdots "Copying fonts and png..."
fn_scriptlog "Copying fonts and png"
sleep 1
find "${addonsdir}" -name '*.otf' | cpio --quiet -updm "${fastdldir}"
find "${addonsdir}" -name '*.ttf' | cpio --quiet -updm "${fastdldir}"
find "${addonsdir}" -name '*.png' | cpio --quiet -updm "${fastdldir}"
fn_printok "Fonts and png copied"
echo -en "\n"
sleep 1

# Correct addons folder structure
if [ -d "${fastdldir}/addons" ]; then
	fn_printinfo "Correcting file structure"
	fn_scriptlog "Correcting file structure"
	sleep 2
	echo "Copying those files to their correct folder"
	sleep 2
	cp -Rf "${fastdldir}"/addons/*/* "${fastdldir}"
	# As we're not sure about the correct file structure, duplicate instead of remove
	# rm -R "${fastdldir}/addons"
	fn_printok "Corrected file structure"
	echo -en "\n"
	sleep 1
fi

# Correct content that may be into a lua folder by mistake like some darkrpmodification addons
if [ -d "${fastdldir}/lua" ]; then
	fn_printdots "Stupid file structure fix"
	sleep 1
	cp -Rf "${fastdldir}/lua/"* "${fastdldir}"
	fn_printok "Stupid file structure fixed"
	echo -en "\n"
	sleep 1
fi
}

fn_fastdl_bzip2(){
# Compressing using bzip2 if user said yes
if [ ${bzip2enable} == "on" ]; then
	fn_printinfo "Compressing files using bzip2..."
	fn_scriptlog "Compressing files using bzip2..."
	sleep 2
	# bzip2 all files that are not already compressed (keeping original files)
	find "${fastdldir}" -not -name \*.bz2 -exec bzip2 -qk \{\} \;
	fn_printinfo "bzip2 compression done"
	fn_scriptlog "bzip2 compression done"
	sleep 1
fi
}

# Generate lua file that will force download any file into the FastDL folder
fn_lua_fastdl(){
# Remove lua file if luaressource is turned off and file exists
if [ "${luaressource}" == "off" ]; then
	if [ -f "${luafastdlfullpath}" ]; then
		echo "Removing download enforcer"
		sleep 1
		rm -R "${luafastdlfullpath}"
	fi
fi
# Remove old lua file and generate a new one if user said yes
if [ "${luaressource}" == "on" ]; then
	if [ -f "${luafastdlfullpath}" ]; then
		fn_printdots "Removing old download enforcer"
		sleep 1
		rm "${luafastdlfullpath}"
		fn_printok "Removed old download enforcer"
		fn_scriptlog "Removed old download inforcer"
		echo -en "\n"
		sleep 1
	fi
	fn_printdots "Generating new download enforcer"
	fn_scriptlog "Generating new download enforcer"
	sleep 1
	# Read all filenames and put them into a lua file at the right path
	find "${fastdldir}" \( -name "." ! -name "*.bz2" \) -printf '%P\n' | while read line; do
		echo "resource.AddFile("\""${line}"\"")" >> "${luafastdlfullpath}"
	done
	fn_printok "Download enforcer generated"
	fn_scriptlog "Download enforcer generated"
	echo -en "\n"
	sleep 1
fi
}

fn_fastdl_completed(){
# Finished message
fn_printok "Congratulations, it's done"
fn_scriptlog "FastDL job done"
echo "For more information, see https://github.com/dgibbs64/linuxgsm/wiki/Fastdl"
echo -en "\n"
if [ "$bzip2installed" == "0" ]; then
echo "By the way, you'd better install bzip2 an re-run this command"
fi
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

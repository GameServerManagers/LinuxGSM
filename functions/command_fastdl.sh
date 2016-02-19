#!/bin/bash
# LGSM command_fastdl function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: http://gameservermanagers.com
lgsm_version="190216"

# Description: Creates a FastDL folder

local modulename="FastDL Creator"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh

# Directories
webdir="${rootdir}/www"
fastdldir="${webdir}/fastdl"
# Server lua autorun dir, used to autorun lua on client connect to the server
luasvautorundir="${systemdir}/lua/audoturn/server"
luafastdlfile="lgsm_cl_force_fastdl.lua"
luafastdlfullpath="${luasvautorundir}/${luafastdlfile}"

fn_fastdl_init(){
# User confirmation for starting process
echo "Generate a FastDL Folder ?"
while true; do
	read -p "Continue? [y/N]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) exit;;
	* ) echo "Please answer yes or no.";;
	esac
done
# Create FastDL folder if it doesn't exit
if [ ! -d "${webdir}" ]; then
	echo "Creating www directory"
	mkdir -v "${webdir}"
	sleep 1
fi
if [ ! -d "${fastdldir}" ]; then
	echo "Creating FastDL directory"
	mkdir -v "${fastdldir}"
	sleep 1
else
	echo "Updating FastDL..."
fi
# Ask for lua resource add file use
echo "Do you wish to generate a lua file to force clients to download all FastDL content ?"
echo "It is useful for many addons where devs didn't register their files to be downloaded through FastDL."
while true; do
	read -p "Continue? [y/n]" yn
	case $yn in
	[Yy]* ) luaressource="on"; break;;
	[Nn]* ) luaressource="off"; return 0;;
	* ) echo "Please answer yes or no.";;
	esac
done
}

fn_gmod_fastdl(){
# Copy all needed files for fastDL
echo "Gathering all needed FastDL files..."
sleep 1

cd "${systemdir}"

# Map Files
echo "Copying map files"
sleep 1
find . -name '*.bsp' | cpio -updm "${fastdldir}"
echo "Done"
sleep 1

# Materials
echo "Copying Materials"
sleep 1
find . -name '*.vtf' | cpio -updm "${fastdldir}"
find . -name '*.vmt' | cpio -updm "${fastdldir}"
echo "Done"
sleep 1

# Models
echo "Copying Models"
sleep 1
find . -name '*.vtx' | cpio -updm "${fastdldir}"
find . -name '*.vvd' | cpio -updm "${fastdldir}"
find . -name '*.mdl' | cpio -updm "${fastdldir}"
find . -name '*.phy' | cpio -updm "${fastdldir}"
echo "Done"
sleep 1

# Particles
echo "Copying Particles"
sleep 1
find . -name '*.pcf' | cpio -updm "${fastdldir}"
echo "Done"
sleep 1

# Sounds
echo "Copying Sounds"
sleep 1
find . -name '*.wav' | cpio -updm "${fastdldir}"
find . -name '*.mp3' | cpio -updm "${fastdldir}"
find . -name '*.ogg' | cpio -updm "${fastdldir}"
echo "Done"
sleep 1

# Resources (mostly fonts)
echo "Copying fonts and png"
sleep 1
find . -name '*.otf' | cpio -updm "${fastdldir}"
find . -name '*.ttf' | cpio -updm "${fastdldir}"
find . -name '*.png' | cpio -updm "${fastdldir}"
echo "Done"
sleep 1

# Going back to scriptfolder to avoid mistakes
cd "${rootdir}"

# Correct addons folder structure
if [ -d "${fastdldir}/addons" ]; then
	echo "Possible FastDL files found into addons"
	echo "Moving those files to their correct folder"
	sleep 2
	cp -Rf "${fastdldir}"/addons/*/* "${fastdldir}"
	rm -R "${fastdldir}/addons"
	echo "Done"
	sleep 1
fi

# Correct content that may be into a lua folder by mistake like some darkrpmodification addons
if [ -d "${fastdldir}/lua" ]; then
	echo "Some FastDL files (often addons in darkrpmodifications) may be in the wrong folder"
	sleep 1
	echo "Copying those files to their hopefully correct locations"
	sleep 1
	cp -Rf "${fastdldir}/lua/"* "${fastdldir}"
	echo "Done"
	sleep 1
fi
}


# bzip2 compression
fn_check_bzip2(){
# Returns true if not installed
if [ -z "$(command -v bzip2)" ]; then
	bzip2installed="0"
	echo "WARNING bzip2 packed is not installed !"
	sleep 2
	echo "You can't compress your FastDL files !"
	sleep 2
	echo "Loading time won't be as good as possible for your players."
	sleep 2
	echo "It's advised that your install bzip2 and re-run the fastdl command."
	sleep 3
else
	bzip2installed="1"
fi
}

fn_fastdl_bzip2(){
echo "Do you want to compress files using bzip2 for even faster client download ?"
echo "It may take a while..."
	while true; do
		read -p "Continue? [y/N]" yn
		case $yn in
		[Yy]* ) break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
		esac
	done

echo "Compressing files using bzip2..."
sleep 2

# bzip2 all files that are not already compressed (keeping original files)
find "${fastdldir}" -not -name \*.bz2 -exec bzip2 -k \{\} \;
echo "bzip2 compression done"
sleep 1
}

# Generate lua file that will force download any file into the FastDL folder
fn_lua_fastdl(){
# Remove lua file if luaressource is turned off
if [ "${luaressource}" == "off" ]; then
	if [ -f "${luafastdlfullpath}" ]; then
		echo "Removing download enforcer"
		sleep 1
		rm -R "${luafastdlfullpath}"
	fi
fi
if [ "${luaressource}" == "on" ]; then
	if [ -f "${luafastdlfullpath}" ]; then
		echo "Removing old download enforcer"
		sleep 1
		rm "${luafastdlfullpath}"
	fi
	echo "Generating new download enforcer"
	sleep 1
	find "${fastdldir}" \( -name "." ! -name "*.bz2" \) -printf '%P\n' | while read line; do
		echo "resource.AddFile("\""${line}"\"")" >> "${luafastdlfullpath}"
	done
	echo "Download enforcer generated"
	sleep 1
fi
}

fn_fastdl_completed(){
echo "----------------------------------"
echo "Congratulations, it's done"
echo "Now you should configure your HTTP server to target the fastdl folder that was created in ${fastdldir}"
echo "Or copy files to an external server"
echo "Don't forget to change your sv_downloadurl accordingly in ${servercfgfullpath}"
echo "You may want to use the www folder to host a loadingurl too,"
echo "for that purpose, just make a loadingurl folder next to the fastdl folder and put your loadingurl in it"
if [ "$bzip2installed" == "0" ]; then
echo "By the way, you'd better install bzip2 an re-run this command"
fi
echo "----------------------------------"
exit
}

# Game checking
# Garry's Mod
if [ "${gamename}" == "Garry's Mod" ]; then
	fn_fastdl_init
	fn_gmod_fastdl
	fn_check_bzip2
	if [ "${bzip2installed}" == "1" ]; then
		fn_fastdl_bzip2
	fi
	fn_lua_fastdl
	fn_fastdl_completed
	exit
fi

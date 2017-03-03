#!/bin/bash
# LinuxGSM command_fastdl.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Creates a FastDL directory.

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
		fn_print_info "bzip2 is not installed! Install it to enable file compression"
		fn_script_log_info "bzip2 is not installed. Install it to enable file compression."
		fn_script_log_info "https://github.com/GameServerManagers/LinuxGSM/wiki/FastDL#bzip2-compression"
		echo -en "\n"
		sleep 1
		echo " * https://github.com/GameServerManagers/LinuxGSM/wiki/FastDL#bzip2-compression"
		sleep 2
		echo ""
	else
		bzip2installed="1"
	fi
}

# Prompts user for FastDL creation settings
fn_fastdl_config(){
	echo "FastDL setup"
	echo "================================="

	# Prompt for clearing old files if directory was already here
	if [ -d "${fastdldir}" ]; then
		fn_print_warning_nl "FastDL directory already exists."
		echo "${fastdldir}"
		echo ""
		if fn_prompt_yn "Overwrite existing directory?" Y; then
			clearoldfastdl="on"
		else
			clearoldfastdl="off"
		fi
	fi

	# Garry's Mod Specific
	if [ "${gamename}" == "Garry's Mod" ]; then
		# Prompt to clear addons dir from fastdl, can use unnecessary space or be required depending on addon's file structures
		fn_print_dots
		if fn_prompt_yn "Clear addons dir from fastdl dir?" Y; then
			cleargmodaddons="on";
		else
			cleargmodaddons="off";
		fi

		# Prompt for download enforcer, which is using a .lua addfile resource generator
		fn_print_dots
		if fn_prompt_yn "Use client download enforcer?" Y; then
			luaressource="on"
		else
			luaressource="off"
		fi
	fi
}

fn_fastdl_dirs(){
	# Check and create directories
	if [ ! -d "${modsdir}" ];then
		echo -en "creating web directory ${webdir}..."
		mkdir -p "${webdir}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "creating web directory ${webdir}..."
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "creating web directory ${webdir}..."
		fi
		sleep 0.5
	fi
	if [ ! -d "${fastdldir}" ];then
		echo -en "creating fastdl directory ${fastdldir}..."
		mkdir -p "${fastdldir}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "creating fastdl directory ${fastdldir}..."
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "creating fastdl directory ${fastdldir}..."
		fi
		sleep 0.5
	fi
}

fn_clear_old_fastdl(){
	# Clearing old FastDL if user answered yes
	if [ ! -d "${modsdir}" ];then
		echo -en "clearing existing FastDL directory ${fastdldir}..."
		rm -R "${fastdldir:?}"/*
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "clearing existing FastDL directory ${fastdldir}..."
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "clearing existing FastDL directory ${fastdldir}..."
		fi
		sleep 0.5
	fi
}

fn_fastdl_gmod(){
	# Copy all needed files for FastDL
	echo ""
	fn_print_dots "Starting gathering all needed files"
	fn_script_log "Starting gathering all needed files"
	sleep 1
	echo -en "\n"

	# No choice to cd to the directory, as find can't then display relative directory
	cd "${systemdir}" || exit

	# Map Files
	fn_print_dots "Copying map files..."
	fn_script_log "Copying map files"
	sleep 0.5
	find . -name '*.bsp' | cpio --quiet -updm "${fastdldir}"
	find . -name '*.ain' | cpio --quiet -updm "${fastdldir}"
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

	# Correct addons directory structure for FastDL
	if [ -d "${fastdldir}/addons" ]; then
		fn_print_info "Adjusting addons' file structure"
		fn_script_log "Adjusting addons' file structure"
		sleep 1
		cp -Rf "${fastdldir}"/addons/*/* "${fastdldir}"
		fn_print_ok "Adjusted addons' file structure"
		sleep 1
		echo -en "\n"
		# Clear addons directory in fastdl
		if [ "${cleargmodaddons}" == "on" ]; then
			fn_print_info "Clearing addons dir from fastdl dir"
			fn_script_log "Clearing addons dir from fastdl dir"
			sleep 1
			rm -R "${fastdldir:?}/addons"
			fn_print_ok "Cleared addons dir from fastdl dir"
			sleep 1
			echo -en "\n"
		fi
	fi

	# Correct content that may be into a lua directory by mistake like some darkrpmodification addons
	if [ -d "${fastdldir}/lua" ]; then
		fn_print_dots "Typical DarkRP files detected, fixing"
		sleep 2
		cp -Rf "${fastdldir}/lua/"* "${fastdldir}"
		fn_print_ok "Stupid DarkRP file structure fixed"
		sleep 2
		echo -en "\n"
	fi
}

# Using this gist https://gist.github.com/agunnerson-ibm/efca449565a3e7356906
fn_human_readable_file_size() {
    local abbrevs=(
        $((1 << 60)):ZB
        $((1 << 50)):EB
        $((1 << 40)):TB
        $((1 << 30)):GB
        $((1 << 20)):MB
        $((1 << 10)):KB
        $((1)):bytes
    )

    local bytes="${1}"
    local precision="${2}"

    if [[ "${bytes}" == "1" ]]; then
        echo "1 byte"
    else
        for item in "${abbrevs[@]}"; do
            local factor="${item%:*}"
            local abbrev="${item#*:}"
            if [[ "${bytes}" -ge "${factor}" ]]; then
                local size="$(bc -l <<< "${bytes} / ${factor}")"
                printf "%.*f %s\n" "${precision}" "${size}" "${abbrev}"
                break
            fi
        done
    fi
}

fn_fastdl_source(){
	# Copy all needed files for FastDL
	if [ -n "${copyflag}" ]; then
		# Removes all existing FastDL files.
		if [ -d "${fastdldir}" ]; then
			echo -e "removing existing FastDL files"
			sleep 0.1
			fileswc=1
			totalfileswc=$(find "${fastdldir}" | wc -l)
			tput sc
			while read -r filetoremove; do
				tput rc; tput el
				printf "removing ${fileswc} / ${totalfileswc} : ${filetoremove}..."
				((fileswc++))
				rm -rf "${filetoremove}"
				((exitcode=$?))
				if [ ${exitcode} -ne 0 ]; then
					fn_script_log_fatal "Removing ${filetoremove}"
					break
				else
					fn_script_log_pass "Removing ${filetoremove}"
				fi
				sleep 0.01
			done < <(find "${fastdldir}")
			if [ ${exitcode} -ne 0 ]; then
				fn_print_fail_eol_nl
				core_exit.sh
			else
				fn_print_ok_eol_nl
			fi
		fi
		fn_fastdl_dirs

		echo -e "copying files to ${fastdldir}"
		fn_script_log "copying files to ${fastdldir}"
	else
		if [ -f "${tmpdir}/fastdl_files_to_compress.txt" ]; then
			rm -f "${tmpdir}/fastdl_files_to_compress.txt"
		fi
		echo -e "analyzing required files"
		fn_script_log "analyzing required files"
	fi

	local directorys_array_=( "maps" "materials" "particles" "sounds" "*.txt" )
	for directory in "${directorys_array[@]}"
	do
		if [ -d "${systemdir}/${directory}" ]; then
			if [ "${directory}" == "maps" ]; then
				local allowed_extentions_array_=( "*.bsp" "*.ain" "*.nav" "*.jpg" "*.txt" )
			elif [ "${directory}" == "materials" ]; then
				local allowed_extentions_array=( "*.vtf" "*.vmt" "*.vbf" )
			elif [ "${directory}" == "particles" ]; then
				local allowed_extentions_array=( "*.pcf" )
			elif [ "${directory}" == "sounds" ]; then
				local allowed_extentions_array=( "*.vtx" "*.vvd" "*.mdl" "*.mdl" "*.phy" "*.jpg" "*.png" )
			fi
			for allowed_extention in "${allowed_extentions_array[@]}"
			do
				fileswc=0
				tput sc
				if [ -z "${copyflag}" ]; then
					tput rc; tput el
					printf "gathering ${directory} ${allowed_extention} : ${fileswc}..."
				fi
				while read -r mapfile; do
					((fileswc++))
					if [ -n "${copyflag}" ]; then
						tput rc; tput el
						printf "copying ${directory} ${allowed_extention} : ${fileswc}..."
						if [ ! -d "${fastdldir}/${directory}" ]; then
							mkdir "${fastdldir}/${directory}"
						fi
						cp "${mapfile}" "${fastdldir}/${directory}"
					else
						tput rc; tput el
						printf "gathering ${directory} ${allowed_extention} : ${fileswc}..."
						sleep 0.01
						echo "${mapfile}" >> "${tmpdir}/fastdl_files_to_compress.txt"
					fi
				done < <(find "${systemdir}/${directory}" -type f -iname ${allowed_extention})

				if [ -z "${copyflag}" ]; then
					tput rc; tput el
					printf "gathering ${directory} ${allowed_extention} : ${fileswc}..."
				fi
				if [ ${fileswc} != 0 ]&&[ -n "${copyflag}" ]||[ -z "${copyflag}" ]; then
					fn_print_ok_eol_nl
				fi
			done
		fi
	done

	if [ -f "${tmpdir}/fastdl_files_to_compress.txt" ]; then
		totalfiles=$(wc -l < "${tmpdir}/fastdl_files_to_compress.txt")
		# Calculates total file size
		while read dufile; do
			filesize=$(du -b "${dufile}"| awk '{ print $1 }')
			filesizetotal=$(( ${filesizetotal} + ${filesize} ))
		done <"${tmpdir}/fastdl_files_to_compress.txt"
	fi

	if [ -z "${copyflag}" ]; then
		echo "about to compress ${totalfiles} files, total size $(fn_human_readable_file_size ${filesizetotal} 0) "
		if [ -f "${tmpdir}/fastdl_files_to_compress.txt" ]; then
			rm "${tmpdir}/fastdl_files_to_compress.txt"
		fi
		if fn_prompt_yn "Continue?" Y; then
			copyflag=1
			fn_fastdl_source
		else
			core_exit.sh
		fi
	else
		fn_fastdl_bzip2
	fi
}

# Generate lua file that will force download any file into the FastDL directory
fn_fastdl_gmod_lua_enforcer(){
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
		find "${fastdldir:?}" \( -type f ! -name "*.bz2" \) -printf '%P\n' | while read line; do
			echo "resource.AddFile( "\""${line}"\"" )" >> "${luafastdlfullpath}"
		done
		fn_print_ok "Download enforcer generated"
		fn_script_log "Download enforcer generated"
		echo -en "\n"
		echo ""
		sleep 2
	fi
}

fn_fastdl_bzip2(){
	while read -r filetocompress; do
		echo -en "compressing ${filetocompress}..."
		bzip2 "${filetocompress}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "creating web directory ${webdir}..."
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "creating web directory ${webdir}..."
		fi
	done < <(find  "${fastdldir:?}" \( -type f ! -name "*.bz2" \))
}

fn_fastdl_completed(){
	# Finished message
	echo "FastDL files are located in:"
	echo "${webdir}"
	echo "FastDL completed"
	fn_script_log "FastDL completed"
}

# Run functions
fn_print_header
echo "More info: https://git.io/vyk9a"
echo ""
fn_fastdl_config

if [ "${gamename}" == "Garry's Mod" ]; then
	fn_fastdl_gmod
	fn_fastdl_gmod_lua_enforcer
else
	fn_fastdl_source
fi
fn_fastdl_completed
core_exit.sh

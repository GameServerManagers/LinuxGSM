#!/bin/bash
# LinuxGSM command_fastdl.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Creates a FastDL directory.

local commandname="FASTDL"
local commandaction="FastDL"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

check.sh

# Directories.
if [ -z "${webdir}" ]; then
	webdir="${rootdir}/public_html"
fi
fastdldir="${webdir}/fastdl"
addonsdir="${systemdir}/addons"
# Server lua autorun dir, used to autorun lua on client connect to the server.
luasvautorundir="${systemdir}/lua/autorun/server"
luafastdlfile="lgsm_cl_force_fastdl.lua"
luafastdlfullpath="${luasvautorundir}/${luafastdlfile}"

# Check if bzip2 is installed.
if [ -z "$(command -v bzip2 2>/dev/null)" ]; then
	fn_print_fail "bzip2 is not installed"
	fn_script_log_fatal "bzip2 is not installed"
	core_exit.sh
fi

# Header
fn_print_header
echo -e "More info: https://docs.linuxgsm.com/commands/fastdl"
echo -e ""

# Prompts user for FastDL creation settings.
echo -e "${commandaction} setup"
echo -e "================================="

# Prompt for clearing old files if directory was already here.
if [ -d "${fastdldir}" ]; then
	fn_print_warning_nl "FastDL directory already exists."
	echo -e "${fastdldir}"
	echo -e ""
	if fn_prompt_yn "Overwrite existing directory?" Y; then
		fn_script_log_info "Overwrite existing directory: YES"
	else
		core_exit.sh
	fi
fi

# Garry's Mod Specific.
if [ "${shortname}" == "gmod" ]; then
	# Prompt for download enforcer, which is using a .lua addfile resource generator.
	if fn_prompt_yn "Force clients to download files?" Y; then
		luaresource="on"
		fn_script_log_info "Force clients to download files: YES"
	else
		luaresource="off"
		fn_script_log_info "Force clients to download filesr: NO"
	fi
fi

# Clears any fastdl directory content.
fn_clear_old_fastdl(){
	# Clearing old FastDL.
	if [ -d "${fastdldir}" ]; then
		echo -en "clearing existing FastDL directory ${fastdldir}..."
		rm -R "${fastdldir:?}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Clearing existing FastDL directory ${fastdldir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Clearing existing FastDL directory ${fastdldir}"
		fi
		fn_sleep_time
	fi
}

fn_fastdl_dirs(){
	# Check and create directories.
	if [ ! -d "${webdir}" ]; then
		echo -en "creating web directory ${webdir}..."
		mkdir -p "${webdir}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Creating web directory ${webdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating web directory ${webdir}"
		fi
		fn_sleep_time
	fi
	if [ ! -d "${fastdldir}" ]; then
		echo -en "creating fastdl directory ${fastdldir}..."
		mkdir -p "${fastdldir}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Creating fastdl directory ${fastdldir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating fastdl directory ${fastdldir}"
		fi
		fn_sleep_time
	fi
}

# Using this gist https://gist.github.com/agunnerson-ibm/efca449565a3e7356906
fn_human_readable_file_size(){
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
		echo -e "1 byte"
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

# Provides info about the fastdl directory content and prompts for confirmation.
fn_fastdl_preview(){
	# Remove any file list.
	if [ -f "${tmpdir}/fastdl_files_to_compress.txt" ]; then
		rm -f "${tmpdir}/fastdl_files_to_compress.txt"
	fi
	echo -e "analysing required files"
	fn_script_log_info "Analysing required files"
	# Garry's Mod
	if [ "${shortname}" == "gmod" ]; then
		cd "${systemdir}" || exit
		allowed_extentions_array=( "*.ain" "*.bsp" "*.mdl" "*.mp3" "*.ogg" "*.otf" "*.pcf" "*.phy" "*.png" "*.svg" "*.vtf" "*.vmt" "*.vtx" "*.vvd" "*.ttf" "*.wav" )
		for allowed_extention in "${allowed_extentions_array[@]}"; do
			fileswc=0
			tput sc
			while read -r ext; do
				((fileswc++))
				tput rc; tput el
				printf "gathering ${allowed_extention} : ${fileswc}..."
				echo -e "${ext}" >> "${tmpdir}/fastdl_files_to_compress.txt"
			done < <(find . -type f -iname ${allowed_extention})
			if [ ${fileswc} != 0 ]; then
				fn_print_ok_eol_nl
			else
				fn_print_info_eol_nl
			fi
		done
	# Source engine
	else
		fastdl_directories_array=( "maps" "materials" "models" "particles" "sound" "resources" )
		for directory in "${fastdl_directories_array[@]}"; do
			if [ -d "${systemdir}/${directory}" ]; then
				if [ "${directory}" == "maps" ]; then
					local allowed_extentions_array=( "*.bsp" "*.ain" "*.nav" "*.jpg" "*.txt" )
				elif [ "${directory}" == "materials" ]; then
					local allowed_extentions_array=( "*.vtf" "*.vmt" "*.vbf" "*.png" "*.svg" )
				elif [ "${directory}" == "models" ]; then
					local allowed_extentions_array=( "*.vtx" "*.vvd" "*.mdl" "*.phy" "*.jpg" "*.png" )
				elif [ "${directory}" == "particles" ]; then
					local allowed_extentions_array=( "*.pcf" )
				elif [ "${directory}" == "sound" ]; then
					local allowed_extentions_array=( "*.wav" "*.mp3" "*.ogg" )
				fi
				for allowed_extention in "${allowed_extentions_array[@]}"; do
					fileswc=0
					tput sc
					while read -r ext; do
						((fileswc++))
						tput rc; tput el
						printf "gathering ${directory} ${allowed_extention} : ${fileswc}..."
						echo -e "${ext}" >> "${tmpdir}/fastdl_files_to_compress.txt"
					done < <(find "${systemdir}/${directory}" -type f -iname ${allowed_extention})
					tput rc; tput el
					echo -e "gathering ${directory} ${allowed_extention} : ${fileswc}..."
					if [ ${fileswc} != 0 ]; then
						fn_print_ok_eol_nl
					else
						fn_print_info_eol_nl
					fi
				done
			fi
		done
	fi
	if [ -f "${tmpdir}/fastdl_files_to_compress.txt" ]; then
		echo -e "calculating total file size..."
		fn_sleep_time
		totalfiles=$(wc -l < "${tmpdir}/fastdl_files_to_compress.txt")
		# Calculates total file size.
		while read -r dufile; do
			filesize=$(stat -c %s "${dufile}")
			filesizetotal=$(( ${filesizetotal} + ${filesize} ))
			exitcode=$?
			if [ "${exitcode}" != 0 ]; then
				fn_print_fail_eol_nl
				fn_script_log_fatal "Calculating total file size."
				core_exit.sh
			fi
		done <"${tmpdir}/fastdl_files_to_compress.txt"
	else
		fn_print_fail_eol_nl "generating file list"
		fn_script_log_fatal "Generating file list."
		core_exit.sh
	fi
	echo -e "about to compress ${totalfiles} files, total size $(fn_human_readable_file_size ${filesizetotal} 0)"
	fn_script_log_info "${totalfiles} files, total size $(fn_human_readable_file_size ${filesizetotal} 0)"
	rm "${tmpdir}/fastdl_files_to_compress.txt"
	if ! fn_prompt_yn "Continue?" Y; then
		fn_script_log "User exited"
		core_exit.sh
	fi
}

# Builds Garry's Mod fastdl directory content.
fn_fastdl_gmod(){
	cd "${systemdir}" || exit
	for allowed_extention in "${allowed_extentions_array[@]}"
	do
		fileswc=0
		tput sc
		while read -r fastdlfile; do
			((fileswc++))
			tput rc; tput el
			echo -e "copying ${allowed_extention} : ${fileswc}..."
			cp --parents "${fastdlfile}" "${fastdldir}"
			exitcode=$?
			if [ ${exitcode} -ne 0 ]; then
				fn_print_fail_eol_nl
				fn_script_log_fatal "Copying ${fastdlfile} > ${fastdldir}"
				core_exit.sh
			else
				fn_script_log_pass "Copying ${fastdlfile} > ${fastdldir}"
			fi
		done < <(find . -type f -iname "${allowed_extention}")
		if [ ${fileswc} != 0 ]; then
			fn_print_ok_eol_nl
		fi
	done
	# Correct addons directory structure for FastDL.
	if [ -d "${fastdldir}/addons" ]; then
		echo -en "updating addons file structure..."
		cp -Rf "${fastdldir}"/addons/*/* "${fastdldir}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Updating addons file structure"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Updating addons file structure"
		fi
		# Clear addons directory in fastdl.
		echo -en "clearing addons dir from fastdl dir..."
		fn_sleep_time
		rm -R "${fastdldir:?}/addons"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Clearing addons dir from fastdl dir"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Clearing addons dir from fastdl dir"
		fi
	fi
	# Correct content that may be into a lua directory by mistake like some darkrpmodification addons.
	if [ -d "${fastdldir}/lua" ]; then
		echo -en "correcting DarkRP files..."
		fn_sleep_time
		cp -Rf "${fastdldir}/lua/"* "${fastdldir}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Correcting DarkRP files"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Correcting DarkRP files"
		fi
	fi
	if [ -f "${tmpdir}/fastdl_files_to_compress.txt" ]; then
		totalfiles=$(wc -l < "${tmpdir}/fastdl_files_to_compress.txt")
		# Calculates total file size.
		while read dufile; do
			filesize=$(du -b "${dufile}" | awk '{ print $1 }')
			filesizetotal=$(( ${filesizetotal} + ${filesize} ))
		done <"${tmpdir}/fastdl_files_to_compress.txt"
	fi
}

fn_fastdl_source(){
	for directory in "${fastdl_directories_array[@]}"
	do
		if [ -d "${systemdir}/${directory}" ]; then
			if [ "${directory}" == "maps" ]; then
				local allowed_extentions_array=( "*.bsp" "*.ain" "*.nav" "*.jpg" "*.txt" )
			elif [ "${directory}" == "materials" ]; then
				local allowed_extentions_array=( "*.vtf" "*.vmt" "*.vbf" "*.png" "*.svg" )
			elif [ "${directory}" == "models" ]; then
				local allowed_extentions_array=( "*.vtx" "*.vvd" "*.mdl" "*.phy" "*.jpg" "*.png" )
			elif [ "${directory}" == "particles" ]; then
				local allowed_extentions_array=( "*.pcf" )
			elif [ "${directory}" == "sound" ]; then
				local allowed_extentions_array=( "*.wav" "*.mp3" "*.ogg" )
			fi
			for allowed_extention in "${allowed_extentions_array[@]}"
			do
				fileswc=0
				tput sc
				while read -r fastdlfile; do
					((fileswc++))
					tput rc; tput el
					printf "copying ${directory} ${allowed_extention} : ${fileswc}..."
					fn_sleep_time
					# get relative path of file in the dir
					tmprelfilepath="${fastdlfile#"${systemdir}/"}"
					copytodir="${tmprelfilepath%/*}"
					# create relative path for fastdl
					if [ ! -d "${fastdldir}/${copytodir}" ]; then
						mkdir -p "${fastdldir}/${copytodir}"
					fi
					cp "${fastdlfile}" "${fastdldir}/${copytodir}"
					exitcode=$?
					if [ ${exitcode} -ne 0 ]; then
						fn_print_fail_eol_nl
						fn_script_log_fatal "Copying ${fastdlfile} > ${fastdldir}/${copytodir}"
						core_exit.sh
					else
						fn_script_log_pass "Copying ${fastdlfile} > ${fastdldir}/${copytodir}"
					fi
				done < <(find "${systemdir}/${directory}" -type f -iname ${allowed_extention})
				if [ ${fileswc} != 0 ]; then
					fn_print_ok_eol_nl
				fi
			done
		fi
	done
}

# Builds the fastdl directory content.
fn_fastdl_build(){
	# Copy all needed files for FastDL.
	echo -e "copying files to ${fastdldir}"
	fn_script_log_info "Copying files to ${fastdldir}"
	if [ "${shortname}" == "gmod" ]; then
		fn_fastdl_gmod
		fn_fastdl_gmod_dl_enforcer
	else
		fn_fastdl_source
	fi
}

# Generate lua file that will force download any file into the FastDL directory.
fn_fastdl_gmod_dl_enforcer(){
	# Clear old lua file.
	if [ -f "${luafastdlfullpath}" ]; then
		echo -en "removing existing download enforcer: ${luafastdlfile}..."
		rm "${luafastdlfullpath:?}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Removing existing download enforcer ${luafastdlfullpath}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Removing existing download enforcer ${luafastdlfullpath}"
		fi
	fi
	# Generate new one if user said yes.
	if [ "${luaresource}" == "on" ]; then
		echo -en "creating new download enforcer: ${luafastdlfile}..."
		touch "${luafastdlfullpath}"
		# Read all filenames and put them into a lua file at the right path.
		while read -r line; do
			echo -e "resource.AddFile( \"${line}\" )" >> "${luafastdlfullpath}"
		done < <(find "${fastdldir:?}" \( -type f ! -name "*.bz2" \) -printf '%P\n')
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Creating new download enforcer ${luafastdlfullpath}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating new download enforcer ${luafastdlfullpath}"
		fi
	fi
}

# Compresses FastDL files using bzip2.
fn_fastdl_bzip2(){
	while read -r filetocompress; do
		echo -en "\r\033[Kcompressing ${filetocompress}..."
		bzip2 -f "${filetocompress}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Compressing ${filetocompress}"
			core_exit.sh
		else
			fn_script_log_pass "Compressing ${filetocompress}"
		fi
	done < <(find  "${fastdldir:?}" \( -type f ! -name "*.bz2" \))
	fn_print_ok_eol_nl
}

# Run functions.
fn_fastdl_preview
fn_clear_old_fastdl
fn_fastdl_dirs
fn_fastdl_build
fn_fastdl_bzip2
# Finished message.
echo -e "FastDL files are located in:"
echo -e "${fastdldir}"
echo -e "FastDL completed"
fn_script_log_info "FastDL completed"
core_exit.sh

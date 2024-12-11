#!/bin/bash
# LinuxGSM command_fastdl.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Creates a Fastdl directory.

commandname="FASTDL"
commandaction="Fastdl"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

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
if [ ! "$(command -v bzip2 2> /dev/null)" ]; then
	fn_print_fail "bzip2 is not installed"
	fn_script_log_fail "bzip2 is not installed"
	core_exit.sh
fi

# Header
fn_print_header
fn_print_nl "More info: ${italic}https://docs.linuxgsm.com/commands/fastdl"
fn_print_nl ""

# Prompts user for Fastdl creation settings.
fn_print_nl "${bold}${lightyellow}${commandaction} Setup"
fn_messages_separator

# Prompt for clearing old files if directory was already here.
if [ -d "${fastdldir}" ]; then
	fn_print_warning_nl "Fastdl directory already exists."
	fn_print_nl "${fastdldir}"
	fn_print_nl ""
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
fn_clear_old_fastdl() {
	# Clearing old Fastdl.
	if [ -d "${fastdldir}" ]; then
		fn_print "clearing existing Fastdl directory ${fastdldir}"
		rm -rf "${fastdldir:?}"
		exitcode=$?
		if [ "${exitcode}" -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Clearing existing Fastdl directory ${fastdldir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Clearing existing Fastdl directory ${fastdldir}"
		fi
	fi
}

fn_fastdl_dirs() {
	# Check and create directories.
	if [ ! -d "${webdir}" ]; then
		fn_print "creating web directory ${webdir}"
		mkdir -p "${webdir}"
		exitcode=$?
		if [ "${exitcode}" -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Creating web directory ${webdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating web directory ${webdir}"
		fi
	fi
	if [ ! -d "${fastdldir}" ]; then
		fn_print "creating fastdl directory ${fastdldir}"
		mkdir -p "${fastdldir}"
		exitcode=$?
		if [ "${exitcode}" -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Creating fastdl directory ${fastdldir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating fastdl directory ${fastdldir}"
		fi
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
		fn_print_nl "1 byte"
	else
		for item in "${abbrevs[@]}"; do
			local factor="${item%:*}"
			local abbrev="${item#*:}"
			if [[ "${bytes}" -ge "${factor}" ]]; then
				size=$(bc -l <<< "${bytes} / ${factor}")
				printf "%.*f %s\n" "${precision}" "${size}" "${abbrev}"
				break
			fi
		done
	fi
}

# Provides info about the fastdl directory content and prompts for confirmation.
fn_fastdl_preview() {
	# Remove any file list.
	if [ -f "${tmpdir}/fastdl_files_to_compress.txt" ]; then
		rm -f "${tmpdir:?}/fastdl_files_to_compress.txt"
	fi
	fn_print_nl "analysing required files"
	fn_script_log_info "Analysing required files"
	# Garry's Mod
	if [ "${shortname}" == "gmod" ]; then
		cd "${systemdir}" || exit
		allowed_extentions_array=("*.ain" "*.bsp" "*.mdl" "*.mp3" "*.ogg" "*.otf" "*.pcf" "*.phy" "*.png" "*.svg" "*.vtf" "*.vmt" "*.vtx" "*.vvd" "*.ttf" "*.wav")
		for allowed_extention in "${allowed_extentions_array[@]}"; do
			fileswc=0
			tput sc
			while read -r ext; do
				((fileswc++))
				tput rc
				tput el
				fn_print "gathering ${allowed_extention} : ${fileswc}"
				echo -e "${ext}" >> "${tmpdir}/fastdl_files_to_compress.txt"
			done < <(find . -type f -iname "${allowed_extention}")
			if [ ${fileswc} != 0 ]; then
				fn_print_ok_eol_nl
			else
				fn_print_skip_eol_nl
			fi
		done
	# Source engine
	else
		fastdl_directories_array=("maps" "materials" "models" "particles" "sound" "resources")
		for directory in "${fastdl_directories_array[@]}"; do
			if [ -d "${systemdir}/${directory}" ]; then
				if [ "${directory}" == "maps" ]; then
					local allowed_extentions_array=("*.bsp" "*.ain" "*.nav" "*.jpg" "*.txt")
				elif [ "${directory}" == "materials" ]; then
					local allowed_extentions_array=("*.vtf" "*.vmt" "*.vbf" "*.png" "*.svg")
				elif [ "${directory}" == "models" ]; then
					local allowed_extentions_array=("*.vtx" "*.vvd" "*.mdl" "*.phy" "*.jpg" "*.png" "*.vmt" "*.vtf")
				elif [ "${directory}" == "particles" ]; then
					local allowed_extentions_array=("*.pcf")
				elif [ "${directory}" == "sound" ]; then
					local allowed_extentions_array=("*.wav" "*.mp3" "*.ogg")
				fi
				for allowed_extention in "${allowed_extentions_array[@]}"; do
					fileswc=0
					tput sc
					while read -r ext; do
						((fileswc++))
						tput rc
						tput el
						fn_print "gathering ${directory} ${allowed_extention} : ${fileswc}"
						echo -e "${ext}" >> "${tmpdir}/fastdl_files_to_compress.txt"
					done < <(find "${systemdir}/${directory}" -type f -iname "${allowed_extention}")
					tput rc
					tput el
					fn_print "gathering ${directory} ${allowed_extention} : ${fileswc}"
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
		fn_print_nl "calculating total file size"
		fn_sleep_time_1
		totalfiles=$(wc -l < "${tmpdir}/fastdl_files_to_compress.txt")
		# Calculates total file size.
		while read -r dufile; do
			filesize=$(stat -c %s "${dufile}")
			filesizetotal=$((filesizetotal + filesize))
			exitcode=$?
			if [ "${exitcode}" -ne 0 ]; then
				fn_print_fail_eol_nl
				fn_script_log_fail "Calculating total file size"
				core_exit.sh
			fi
		done < "${tmpdir}/fastdl_files_to_compress.txt"
	else
		fn_print_fail_eol_nl "generating file list"
		fn_script_log_fail "Generating file list."
		core_exit.sh
	fi
	fn_print_nl "about to compress ${totalfiles} files, total size $(fn_human_readable_file_size "${filesizetotal}" 0)"
	fn_script_log_info "${totalfiles} files, total size $(fn_human_readable_file_size "${filesizetotal}" 0)"
	rm -f "${tmpdir:?}/fastdl_files_to_compress.txt"
	if ! fn_prompt_yn "Continue?" Y; then
		fn_script_log "User exited"
		core_exit.sh
	fi
}

# Builds Garry's Mod fastdl directory content.
fn_fastdl_gmod() {
	cd "${systemdir}" || exit
	for allowed_extention in "${allowed_extentions_array[@]}"; do
		fileswc=0
		tput sc
		while read -r fastdlfile; do
			((fileswc++))
			tput rc
			tput el
			fn_print "copying ${allowed_extention} : ${fileswc}"
			cp --parents "${fastdlfile}" "${fastdldir}"
			exitcode=$?
			if [ "${exitcode}" -ne 0 ]; then
				fn_print_fail_eol_nl
				fn_script_log_fail "Copying ${fastdlfile} > ${fastdldir}"
				core_exit.sh
			else
				fn_script_log_pass "Copying ${fastdlfile} > ${fastdldir}"
			fi
		done < <(find . -type f -iname "${allowed_extention}")
		if [ ${fileswc} != 0 ]; then
			fn_print_ok_eol_nl
		fi
	done
	# Correct addons directory structure for Fastdl.
	if [ -d "${fastdldir}/addons" ]; then
		fn_print "updating addons file structure..."
		cp -Rf "${fastdldir}"/addons/*/* "${fastdldir}"
		exitcode=$?
		if [ "${exitcode}" -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Updating addons file structure"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Updating addons file structure"
		fi
		# Clear addons directory in fastdl.
		fn_print "clearing addons dir from fastdl dir..."
		fn_sleep_time_1
		rm -rf "${fastdldir:?}/addons"
		exitcode=$?
		if [ "${exitcode}" -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Clearing addons dir from fastdl dir"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Clearing addons dir from fastdl dir"
		fi
	fi
	# Correct content that may be into a lua directory by mistake like some darkrpmodification addons.
	if [ -d "${fastdldir}/lua" ]; then
		fn_print "correcting DarkRP files..."
		fn_sleep_time_1
		cp -Rf "${fastdldir}/lua/"* "${fastdldir}"
		exitcode=$?
		if [ "${exitcode}" -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Correcting DarkRP files"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Correcting DarkRP files"
		fi
	fi
	if [ -f "${tmpdir}/fastdl_files_to_compress.txt" ]; then
		totalfiles=$(wc -l < "${tmpdir}/fastdl_files_to_compress.txt")
		# Calculates total file size.
		while read -r dufile; do
			filesize=$(du -b "${dufile}" | awk '{ print $1 }')
			filesizetotal=$((filesizetotal + filesize))
		done < "${tmpdir}/fastdl_files_to_compress.txt"
	fi
}

fn_fastdl_source() {
	for directory in "${fastdl_directories_array[@]}"; do
		if [ -d "${systemdir}/${directory}" ]; then
			if [ "${directory}" == "maps" ]; then
				local allowed_extentions_array=("*.bsp" "*.ain" "*.nav" "*.jpg" "*.txt")
			elif [ "${directory}" == "materials" ]; then
				local allowed_extentions_array=("*.vtf" "*.vmt" "*.vbf" "*.png" "*.svg")
			elif [ "${directory}" == "models" ]; then
				local allowed_extentions_array=("*.vtx" "*.vvd" "*.mdl" "*.phy" "*.jpg" "*.png")
			elif [ "${directory}" == "particles" ]; then
				local allowed_extentions_array=("*.pcf")
			elif [ "${directory}" == "sound" ]; then
				local allowed_extentions_array=("*.wav" "*.mp3" "*.ogg")
			fi
			for allowed_extention in "${allowed_extentions_array[@]}"; do
				fileswc=0
				tput sc
				while read -r fastdlfile; do
					((fileswc++))
					tput rc
					tput el
					fn_print "copying ${directory} ${allowed_extention} : ${fileswc}"
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
					if [ "${exitcode}" -ne 0 ]; then
						fn_print_fail_eol_nl
						fn_script_log_fail "Copying ${fastdlfile} > ${fastdldir}/${copytodir}"
						core_exit.sh
					else
						fn_script_log_pass "Copying ${fastdlfile} > ${fastdldir}/${copytodir}"
					fi
				done < <(find "${systemdir}/${directory}" -type f -iname "${allowed_extention}")
				if [ ${fileswc} != 0 ]; then
					fn_print_ok_eol_nl
				fi
			done
		fi
	done
}

# Builds the fastdl directory content.
fn_fastdl_build() {
	# Copy all needed files for Fastdl.
	fn_print_nl "copying files to ${fastdldir}"
	fn_script_log_info "Copying files to ${fastdldir}"
	if [ "${shortname}" == "gmod" ]; then
		fn_fastdl_gmod
		fn_fastdl_gmod_dl_enforcer
	else
		fn_fastdl_source
	fi
}

# Generate lua file that will force download any file into the Fastdl directory.
fn_fastdl_gmod_dl_enforcer() {
	# Clear old lua file.
	if [ -f "${luafastdlfullpath}" ]; then
		fn_print "removing existing download enforcer: ${luafastdlfile}"
		rm -f "${luafastdlfullpath:?}"
		exitcode=$?
		if [ "${exitcode}" -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Removing existing download enforcer ${luafastdlfullpath}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Removing existing download enforcer ${luafastdlfullpath}"
		fi
	fi
	# Generate new one if user said yes.
	if [ "${luaresource}" == "on" ]; then
		fn_print "creating new download enforcer: ${luafastdlfile}"
		touch "${luafastdlfullpath}"
		# Read all filenames and put them into a lua file at the right path.
		while read -r line; do
			echo -e "resource.AddFile( \"${line}\" )" >> "${luafastdlfullpath}"
		done < <(find "${fastdldir:?}" \( -type f ! -name "*.bz2" \) -printf '%P\n')
		exitcode=$?
		if [ "${exitcode}" -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Creating new download enforcer ${luafastdlfullpath}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating new download enforcer ${luafastdlfullpath}"
		fi
	fi
}

# Compresses Fastdl files using bzip2.
fn_fastdl_bzip2() {
	while read -r filetocompress; do
		fn_print "compressing ${filetocompress}"
		bzip2 -f "${filetocompress}"
		exitcode=$?
		if [ "${exitcode}" -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Compressing ${filetocompress}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Compressing ${filetocompress}"
		fi
	done < <(find "${fastdldir:?}" \( -type f ! -name "*.bz2" \))
}

check.sh
# Run functions.
fn_fastdl_preview
fn_clear_old_fastdl
fn_fastdl_dirs
fn_fastdl_build
fn_fastdl_bzip2
# Finished message.
fn_print_nl "Fastdl files are located in:"
fn_print_nl "${fastdldir}"
fn_print_nl "Fastdl completed"
fn_script_log_info "Fastdl completed"

core_exit.sh

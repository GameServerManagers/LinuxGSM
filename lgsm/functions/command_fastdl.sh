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
		fn_print_fail "bzip2 is not installed"
		fn_script_log_fatal "bzip2 is not installed"
		core_exit.sh
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
			fn_script_log_info "Overwrite existing directory: YES"
		else
			core_exit.sh
		fi
	fi

	# Garry's Mod Specific
	if [ "${gamename}" == "Garry's Mod" ]; then
		# Prompt to clear addons dir from fastdl, can use unnecessary space or not be required depending on addon's file structures
		if fn_prompt_yn "Clear addons directory from FastDL?" Y; then
			cleargmodaddons="on";
			fn_script_log_info "Clear addons directory from FastDL: YES"
		else
			cleargmodaddons="off";
			fn_script_log_info "Clear addons directory from FastDL: NO"
		fi

		# Prompt for download enforcer, which is using a .lua addfile resource generator
		if fn_prompt_yn "Use client download enforcer?" Y; then
			luaressource="on"
			fn_script_log_info "Use client download enforcer: YES"
		else
			luaressource="off"
			fn_script_log_info "Use client download enforcer: NO"
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
			fn_script_log_fatal "Creating web directory ${webdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating web directory ${webdir}"
		fi
		sleep 0.5
	fi
	if [ ! -d "${fastdldir}" ];then
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
			fn_script_log_fatal "Clearing existing FastDL directory ${fastdldir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Clearing existing FastDL directory ${fastdldir}"
		fi
		sleep 0.5
	fi
}

fn_fastdl_gmod(){
	# Correct addons directory structure for FastDL
	if [ -d "${fastdldir}/addons" ]; then
		echo -en "updating addons file structure..."
		cp -Rf "${fastdldir}"/addons/*/* "${fastdldir}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "updating addons file structure"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "updating addons file structure"
		fi
		# Clear addons directory in fastdl
		if [ "${cleargmodaddons}" == "on" ]; then
			echo -en "clearing addons dir from fastdl dir"
			sleep 1
			rm -R "${fastdldir:?}/addons"
			exitcode=$?
			if [ ${exitcode} -ne 0 ]; then
				fn_print_fail_eol_nl
				fn_script_log_fatal "clearing addons dir from fastdl dir"
				core_exit.sh
			else
				fn_print_ok_eol_nl
				fn_script_log_pass "clearing addons dir from fastdl dir"
			fi
		fi
	fi
	# Correct content that may be into a lua directory by mistake like some darkrpmodification addons
	if [ -d "${fastdldir}/lua" ]; then
		echo -en "correcting DarkRP files..."
		sleep 2
		cp -Rf "${fastdldir}/lua/"* "${fastdldir}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "correcting DarkRP files"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "correcting DarkRP files"
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
		fn_script_log_info "Copying files to ${fastdldir}"
	else
		if [ -f "${tmpdir}/fastdl_files_to_compress.txt" ]; then
			rm -f "${tmpdir}/fastdl_files_to_compress.txt"
		fi
		echo -e "analysing required files"
		fn_script_log_info "Analysing required files"
	fi

	local directorys_array=( "maps" "materials" "particles" "sounds" )
	for directory in "${directorys_array[@]}"
	do
		if [ -d "${systemdir}/${directory}" ]; then
			if [ "${gamename}" == "Garry's Mod" ]; then
				if [ "${directory}" == "maps" ]; then
					local allowed_extentions_array=( "*.bsp" "*.ain" )
				elif [ "${directory}" == "materials" ]; then
					local allowed_extentions_array=( "*.vtf" "*.vmt" )
				elif [ "${directory}" == "models" ]; then
					local allowed_extentions_array=( "*.vtx" "*.vvd" "*.mdl" "*.phy" )
				elif [ "${directory}" == "particles" ]; then
					local allowed_extentions_array=( "*.pcf" )
				elif [ "${directory}" == "sounds" ]; then
					local allowed_extentions_array=( "*.wav" "*.mp3" "*.ogg" )
				elif [ "${directory}" == "resources" ]; then
					local allowed_extentions_array=( "*.otf" "*.ttf" "*.png" )
				fi
			else
				if [ "${directory}" == "maps" ]; then
					local allowed_extentions_array=( "*.bsp" "*.ain" "*.nav" "*.jpg" "*.txt" )
				elif [ "${directory}" == "materials" ]; then
					local allowed_extentions_array=( "*.vtf" "*.vmt" "*.vbf" )
				elif [ "${directory}" == "particles" ]; then
					local allowed_extentions_array=( "*.pcf" )
				elif [ "${directory}" == "sounds" ]; then
					local allowed_extentions_array=( "*.vtx" "*.vvd" "*.mdl" "*.mdl" "*.phy" "*.jpg" "*.png" )
				fi
			fi
			for allowed_extention in "${allowed_extentions_array[@]}"
			do
				fileswc=0
				tput sc
				if [ -z "${copyflag}" ]; then
					tput rc; tput el
					printf "copying ${directory} ${allowed_extention} : ${fileswc}..."
				fi
				while read -r mapfile; do
					((fileswc++))
					if [ -n "${copyflag}" ]; then
						tput rc; tput el
						printf "copying ${directory} ${allowed_extention} : ${fileswc}..."
						sleep 0.01
						if [ ! -d "${fastdldir}/${directory}" ]; then
							mkdir "${fastdldir}/${directory}"
						fi
						cp "${mapfile}" "${fastdldir}/${directory}"
						exitcode=$?
						if [ ${exitcode} -ne 0 ]; then
							fn_print_fail_eol_nl
							fn_script_log_fatal "Copying ${mapfile} > ${fastdldir}/${directory}"
							core_exit.sh
						else
							fn_script_log_pass "Copying ${mapfile} > ${fastdldir}/${directory}"
						fi
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
		echo "about to compress ${totalfiles} files, total size $(fn_human_readable_file_size ${filesizetotal} 0)"
		fn_script_log_info "${totalfiles} files, total size $(fn_human_readable_file_size ${filesizetotal} 0)"
		rm "${tmpdir}/fastdl_files_to_compress.txt"
		if fn_prompt_yn "Continue?" Y; then
			copyflag=1
			fn_fastdl_source
		else
			core_exit.sh
		fi
	else
		if [ "${gamename}" == "Garry's Mod" ]; then
			fn_fastdl_gmod_lua_enforcer
		fi
		fn_fastdl_bzip2
	fi
}

# Generate lua file that will force download any file into the FastDL directory
fn_fastdl_gmod_lua_enforcer(){
	# Clear old lua file
	if [ -f "${luafastdlfullpath}" ]; then
		echo -en "removing existing download enforcer: ${luafastdlfile}..."
		rm "${luafastdlfullpath:?}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "removing existing download enforcer ${luafastdlfullpath}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "removing existing download enforcer ${luafastdlfullpath}"
		fi
	fi
	# Generate new one if user said yes
	if [ "${luaressource}" == "on" ]; then
		echo -en "creating new download enforcer: ${luafastdlfile}..."
		touch "${luafastdlfullpath}"
		# Read all filenames and put them into a lua file at the right path
		find "${fastdldir:?}" \( -type f ! -name "*.bz2" \) -printf '%P\n' | while read line; do
			echo "resource.AddFile( "\""${line}"\"" )" >> "${luafastdlfullpath}"
		done
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "creating new download enforcer ${luafastdlfullpath}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "creating new download enforcer ${luafastdlfullpath}"
		fi
	fi
}

fn_fastdl_bzip2(){
	while read -r filetocompress; do
		echo -en "compressing ${filetocompress}..."
		bzip2 "${filetocompress}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "compressing ${filetocompress}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "compressing ${filetocompress}"
		fi
	done < <(find  "${fastdldir:?}" \( -type f ! -name "*.bz2" \))
}

fn_fastdl_completed(){
	# Finished message
	echo "FastDL files are located in:"
	echo "${webdir}"
	echo "FastDL completed"
	fn_script_log_info "FastDL completed"
}

# Run functions
fn_print_header
echo "More info: https://git.io/vyk9a"
echo ""
fn_fastdl_config
fn_fastdl_source
if [ "${gamename}" == "Garry's Mod" ]; then
	fn_fastdl_gmod
fi
fn_fastdl_completed
core_exit.sh

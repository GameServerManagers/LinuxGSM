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

# File lists.
fastdlfilelist="${tmpdir}/fastdl_files.txt"
fastdlduplicatelist="${tmpdir}/fastdl_files_duplicate.txt"
fastdlnewrecord="${tmpdir}/fastdl_record.txt"
fastdlrecord="${datadir}/${selfname}-fastdl.txt"
fastdlclientlist="${tmpdir}/fastdl_files_client.txt"
fastdlupdatelist="${tmpdir}/fastdl_files_to_update.txt"
fastdlremovelist="${tmpdir}/fastdl_files_to_remove.txt"
fastdlcompresslist="${tmpdir}/fastdl_files_to_compress.txt"
fastdlmaxcompresssize="157286400"

# Header
fn_print_header
fn_print_nl "More info: ${italic}https://docs.linuxgsm.com/commands/fastdl"
fn_print_nl ""

# Prompts user for Fastdl creation settings.
fn_print_nl "${bold}${lightyellow}${commandaction} Setup"
fn_messages_separator

# Prompt for a full rebuild if directory was already here.
fastdlrebuild="off"
if [ -d "${fastdldir}" ]; then
	fn_print_info_nl "Fastdl directory already exists, only changed files will be updated."
	fn_print_nl "${fastdldir}"
	fn_print_nl ""
	if fn_prompt_yn "Rebuild Fastdl directory from scratch? This deletes everything in it." N; then
		fastdlrebuild="on"
		fn_script_log_info "Rebuild Fastdl directory from scratch: YES"
	else
		fn_script_log_info "Rebuild Fastdl directory from scratch: NO"
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
		fn_script_log_info "Force clients to download files: NO"
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
		"1152921504606846976:ZB"
		"1125899906842624:EB"
		"1099511627776:TB"
		"1073741824:GB"
		"1048576:MB"
		"1024:KB"
		"1:bytes"
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

# Sets the GoldSrc file types to include for the current directory.
fn_fastdl_goldsrc_extensions() {
	fastdl_find_maxdepth=()
	if [ "${directory}" == "." ]; then
		allowed_extentions_array=("*.wad")
		fastdl_find_maxdepth=("-maxdepth" "1")
	elif [ "${directory}" == "maps" ]; then
		allowed_extentions_array=("*.bsp" "*.res" "*.txt")
	elif [ "${directory}" == "models" ]; then
		allowed_extentions_array=("*.mdl")
	elif [ "${directory}" == "sound" ]; then
		allowed_extentions_array=("*.wav")
	elif [ "${directory}" == "sprites" ]; then
		allowed_extentions_array=("*.spr" "*.txt")
	elif [ "${directory}" == "gfx" ]; then
		allowed_extentions_array=("*.tga" "*.bmp")
	elif [ "${directory}" == "overviews" ]; then
		allowed_extentions_array=("*.bmp" "*.tga" "*.txt")
	fi
}

# Sets the Source file types to include for the current directory.
fn_fastdl_source_extensions() {
	fastdl_find_maxdepth=()
	if [ "${directory}" == "maps" ]; then
		allowed_extentions_array=("*.bsp" "*.ain" "*.nav" "*.jpg" "*.txt")
	elif [ "${directory}" == "materials" ]; then
		allowed_extentions_array=("*.vtf" "*.vmt" "*.vbf" "*.png" "*.svg")
	elif [ "${directory}" == "models" ]; then
		allowed_extentions_array=("*.vtx" "*.vvd" "*.mdl" "*.phy" "*.jpg" "*.png" "*.vmt" "*.vtf")
	elif [ "${directory}" == "particles" ]; then
		allowed_extentions_array=("*.pcf")
	elif [ "${directory}" == "sound" ]; then
		allowed_extentions_array=("*.wav" "*.mp3" "*.ogg")
	elif [ "${directory}" == "resource" ]; then
		allowed_extentions_array=("*")
	fi
}

# Adds the allowed files in a content directory to the file list.
fn_fastdl_gather() {
	local basedir="${1}"
	local priority="${2}"
	local label="${directory}"
	if [ "${basedir}" != "${systemdir}" ]; then
		label="${basedir#"${systemdir}/"}/${directory}"
	fi
	for allowed_extention in "${allowed_extentions_array[@]}"; do
		fileswc=0
		if [ -z "${plainoutput}" ]; then
			tput sc
		fi
		while IFS=$'\t' read -r filesize filemtime fastdlfile; do
			((fileswc++))
			if [ -z "${plainoutput}" ]; then
				tput rc
				tput el
				fn_print "gathering ${label} ${allowed_extention} : ${fileswc}"
			fi
			fastdlrelpath="${fastdlfile#"${basedir}/"}"
			printf '%s\t%s\t%s\t%s\t%s\n' "${priority}" "${fastdlrelpath#./}" "${filesize}" "${filemtime}" "${fastdlfile}" >> "${fastdlfilelist}"
		done < <(find "${basedir}/${directory}" "${fastdl_find_maxdepth[@]}" -type f -iname "${allowed_extention}" -printf '%s\t%T@\t%p\n')
		if [ -z "${plainoutput}" ]; then
			tput rc
			tput el
		fi
		fn_print "gathering ${label} ${allowed_extention} : ${fileswc}"
		if [ ${fileswc} != 0 ]; then
			fn_print_ok_eol_nl
		else
			fn_print_info_eol_nl
		fi
	done
}

# Adds Garry's Mod files to the file list.
fn_fastdl_gather_gmod() {
	cd "${systemdir}" || exit
	allowed_extentions_array=("*.ain" "*.bsp" "*.mdl" "*.mp3" "*.ogg" "*.otf" "*.pcf" "*.phy" "*.png" "*.svg" "*.vtf" "*.vmt" "*.vtx" "*.vvd" "*.ttf" "*.wav")
	for allowed_extention in "${allowed_extentions_array[@]}"; do
		fileswc=0
		if [ -z "${plainoutput}" ]; then
			tput sc
		fi
		while IFS=$'\t' read -r filesize filemtime fastdlfile; do
			((fileswc++))
			if [ -z "${plainoutput}" ]; then
				tput rc
				tput el
				fn_print "gathering ${allowed_extention} : ${fileswc}"
			fi
			fastdlrelpath="${fastdlfile#./}"
			priority="2"
			if [[ "${fastdlrelpath}" == addons/* ]]; then
				addonname="${fastdlrelpath#addons/}"
				addonname="${addonname%%/*}"
				if [ "addons/${addonname}" == "${fastdlrelpath}" ]; then
					continue
				fi
				priority="1:${addonname}"
				fastdlrelpath="${fastdlrelpath#addons/"${addonname}"/}"
			fi
			printf '%s\t%s\t%s\t%s\t%s\n' "${priority}" "${fastdlrelpath}" "${filesize}" "${filemtime}" "${systemdir}/${fastdlfile#./}" >> "${fastdlfilelist}"
			if [[ "${fastdlrelpath}" == lua/* ]]; then
				printf '%s\t%s\t%s\t%s\t%s\n' "0" "${fastdlrelpath#lua/}" "${filesize}" "${filemtime}" "${systemdir}/${fastdlfile#./}" >> "${fastdlfilelist}"
			fi
		done < <(find . -type f -iname "${allowed_extention}" -printf '%s\t%T@\t%p\n')
		if [ -z "${plainoutput}" ]; then
			tput rc
			tput el
		fi
		fn_print "gathering ${allowed_extention} : ${fileswc}"
		if [ ${fileswc} != 0 ]; then
			fn_print_ok_eol_nl
		else
			fn_print_skip_eol_nl
		fi
	done
}

# Works out which files need to be copied, compressed or removed.
fn_fastdl_plan() {
	LC_ALL=C sort -t $'\t' -k2,2 -k1,1 "${fastdlfilelist}" | awk -F '\t' -v dupes="${fastdlduplicatelist}" 'seen[$2]++ { print $5 " > " $2 > dupes; next } { print }' > "${fastdlfilelist}.sorted"
	mv -f "${fastdlfilelist}.sorted" "${fastdlfilelist}"
	if [ -f "${fastdlduplicatelist}" ]; then
		duplicatefiles=$(wc -l < "${fastdlduplicatelist}")
		while read -r duplicatefile; do
			fn_script_log_info "Skipping ${duplicatefile}, already provided by a higher priority path"
		done < "${fastdlduplicatelist}"
	fi

	declare -A fastdlrecordsource=()
	declare -A fastdlexpected=()
	if [ "${fastdlrebuild}" != "on" ] && [ -f "${fastdlrecord}" ] && [ "$(head -n 1 "${fastdlrecord}")" == "${fastdldir}" ]; then
		while IFS=$'\t' read -r fastdltarget recordsource; do
			[ -n "${fastdltarget}" ] && fastdlrecordsource["${fastdltarget}"]="${recordsource}"
		done < <(tail -n +2 "${fastdlrecord}")
	fi
	echo "${fastdldir}" > "${fastdlnewrecord}"

	read -ra fastdlexcludearray <<< "${fastdlexclude}"
	while IFS=$'\t' read -r priority fastdlrelpath filesize filemtime fastdlfile; do
		for excludepath in "${fastdlexcludearray[@]}"; do
			# shellcheck disable=SC2254
			case "${fastdlrelpath}" in
				${excludepath#/}*)
					((excludedfiles++))
					continue 2
					;;
			esac
		done
		if [ "${engine}" == "goldsrc" ] || [ "${filesize}" -gt "${fastdlmaxcompresssize}" ]; then
			fastdlmode="copy"
			fastdltarget="${fastdlrelpath}"
			if [ "${engine}" != "goldsrc" ]; then
				((largefiles++))
			fi
		else
			fastdlmode="compress"
			fastdltarget="${fastdlrelpath}.bz2"
		fi
		fastdlsource="${fastdlfile}"$'\t'"${filesize}"$'\t'"${filemtime}"
		fastdlexpected["${fastdltarget}"]="on"
		printf '%s\t%s\n' "${fastdltarget}" "${fastdlsource}" >> "${fastdlnewrecord}"
		echo "${fastdlrelpath}" >> "${fastdlclientlist}"
		if [ ! -f "${fastdldir}/${fastdltarget}" ] || [ "${fastdlrecordsource["${fastdltarget}"]}" != "${fastdlsource}" ]; then
			printf '%s\t%s\t%s\n' "${fastdlmode}" "${fastdlrelpath}" "${fastdlfile}" >> "${fastdlupdatelist}"
			((updatefiles++))
			filesizetotal=$((filesizetotal + filesize))
			if [ "${fastdlmode}" == "compress" ]; then
				((compressfiles++))
			fi
		else
			((unchangedfiles++))
		fi
	done < "${fastdlfilelist}"

	for fastdltarget in "${!fastdlrecordsource[@]}"; do
		if [ -z "${fastdlexpected["${fastdltarget}"]}" ] && [ -f "${fastdldir}/${fastdltarget}" ]; then
			echo "${fastdltarget}" >> "${fastdlremovelist}"
			((removefiles++))
		fi
	done
	if [ -d "${fastdldir}" ] && [ "${fastdlrebuild}" != "on" ]; then
		while read -r fastdltarget; do
			if [ -z "${fastdlexpected["${fastdltarget}"]}" ] && [ -z "${fastdlrecordsource["${fastdltarget}"]}" ]; then
				((untrackedfiles++))
			fi
		done < <(find "${fastdldir}" -type f -printf '%P\n')
	fi
}

# Provides info about the fastdl directory content and prompts for confirmation.
fn_fastdl_preview() {
	# Remove any file list.
	rm -f "${fastdlfilelist:?}" "${fastdlduplicatelist:?}" "${fastdlnewrecord:?}" "${fastdlclientlist:?}" "${fastdlupdatelist:?}" "${fastdlremovelist:?}" "${fastdlcompresslist:?}"
	touch "${fastdlclientlist}"
	totalfiles=0
	untrackedfiles=0
	duplicatefiles=0
	excludedfiles=0
	largefiles=0
	updatefiles=0
	compressfiles=0
	unchangedfiles=0
	removefiles=0
	filesizetotal=0
	fn_print_nl "analysing required files"
	fn_script_log_info "Analysing required files"
	# Garry's Mod
	if [ "${shortname}" == "gmod" ]; then
		fn_fastdl_gather_gmod
	# Source and GoldSrc engines
	else
		if [ "${engine}" == "goldsrc" ]; then
			fastdl_directories_array=("." "maps" "models" "sound" "sprites" "gfx" "overviews")
		else
			fastdl_directories_array=("maps" "materials" "models" "particles" "sound" "resource")
		fi
		fastdl_custom_array=()
		if [ "${engine}" == "source" ] && [ -d "${systemdir}/custom" ]; then
			while IFS= read -r -d '' customdir; do
				fastdl_custom_array+=("${customdir}")
			done < <(find "${systemdir}/custom" -mindepth 1 -maxdepth 1 -type d -print0 | LC_ALL=C sort -z)
		fi
		for directory in "${fastdl_directories_array[@]}"; do
			if [ "${engine}" == "goldsrc" ]; then
				fn_fastdl_goldsrc_extensions
			else
				fn_fastdl_source_extensions
			fi
			for customdir in "${fastdl_custom_array[@]}"; do
				if [ -d "${customdir}/${directory}" ]; then
					fn_fastdl_gather "${customdir}" "0:${customdir##*/}"
				fi
			done
			if [ -d "${systemdir}/${directory}" ]; then
				fn_fastdl_gather "${systemdir}" "1"
			fi
		done
	fi
	if [ -f "${fastdlfilelist}" ]; then
		fn_print_nl "calculating changes"
		fn_sleep_time_1
		totalfiles=$(wc -l < "${fastdlfilelist}")
		fn_fastdl_plan
	else
		fn_print_fail_eol_nl "generating file list"
		fn_script_log_fail "Generating file list."
		core_exit.sh
	fi

	echo -e "found ${totalfiles} files: ${unchangedfiles} unchanged, ${excludedfiles} excluded, ${duplicatefiles} duplicate"
	if [ "${updatefiles}" -gt 0 ]; then
		if [ "${engine}" == "source" ]; then
			echo -e "about to update ${updatefiles} files, ${compressfiles} to compress, total size $(fn_human_readable_file_size "${filesizetotal}" 0)"
		elif [ "${engine}" == "goldsrc" ]; then
			echo -e "about to copy ${updatefiles} files, total size $(fn_human_readable_file_size "${filesizetotal}" 0)"
		fi
	fi
	if [ "${largefiles}" -gt 0 ]; then
		echo -e "${largefiles} files over 150 MB will be copied without compression"
	fi
	if [ "${removefiles}" -gt 0 ]; then
		echo -e "about to remove ${removefiles} files no longer on the server"
	fi
	if [ "${untrackedfiles}" -gt 0 ]; then
		echo -e "${untrackedfiles} files in the Fastdl directory were not added by ${selfname} and will be left alone"
	fi
	if [ "${updatefiles}" -eq 0 ] && [ "${removefiles}" -eq 0 ]; then
		echo -e "Fastdl directory is up to date"
	fi

	fn_script_log_info "${totalfiles} files, ${updatefiles} to update, ${unchangedfiles} unchanged, ${excludedfiles} excluded, ${removefiles} to remove, total size $(fn_human_readable_file_size "${filesizetotal}" 0)"
	if ! fn_prompt_yn "Continue?" Y; then
		exitcode=0
		core_exit.sh
	fi
}

# Removes files from the fastdl directory that are no longer on the server.
fn_fastdl_remove() {
	if [ -s "${fastdlremovelist}" ]; then
		fn_print "removing ${removefiles} files no longer on the server"
		while read -r fastdlstalefile; do
			rm -f "${fastdldir:?}/${fastdlstalefile}"
			exitcode=$?
			if [ "${exitcode}" -ne 0 ]; then
				fn_print_fail_eol_nl
				fn_script_log_fail "Removing ${fastdldir}/${fastdlstalefile}"
				core_exit.sh
			else
				fn_script_log_pass "Removing ${fastdldir}/${fastdlstalefile}"
			fi
		done < "${fastdlremovelist}"
		find "${fastdldir:?}" -mindepth 1 -type d -empty -delete
		fn_print_ok_eol_nl
	fi
}

# Copies new and changed files to the fastdl directory.
fn_fastdl_copy() {
	if [ -s "${fastdlupdatelist}" ]; then
		fileswc=0
		if [ -z "${plainoutput}" ]; then
			tput sc
		fi
		while IFS=$'\t' read -r fastdlmode fastdlrelpath fastdlfile; do
			((fileswc++))
			if [ -z "${plainoutput}" ]; then
				tput rc
				tput el
				fn_print "copying files : ${fileswc}/${updatefiles}"
			fi
			fastdltarget="${fastdldir}/${fastdlrelpath}"
			mkdir -p "${fastdltarget%/*}" && cp -p "${fastdlfile}" "${fastdltarget}"
			exitcode=$?
			if [ "${exitcode}" -ne 0 ]; then
				fn_print_fail_eol_nl
				fn_script_log_fail "Copying ${fastdlfile} > ${fastdltarget}"
				core_exit.sh
			else
				fn_script_log_pass "Copying ${fastdlfile} > ${fastdltarget}"
			fi
			if [ "${fastdlmode}" == "compress" ]; then
				printf '%s\0' "${fastdltarget}" >> "${fastdlcompresslist}"
			fi
		done < "${fastdlupdatelist}"
		if [ -n "${plainoutput}" ]; then
			fn_print "copying files : ${fileswc}/${updatefiles}"
		fi
		fn_print_ok_eol_nl
	fi
}

# Builds the fastdl directory content.
fn_fastdl_build() {
	# Copy all needed files for Fastdl.
	fn_print_nl "updating files in ${fastdldir}"
	fn_script_log_info "Updating files in ${fastdldir}"
	fn_fastdl_remove
	fn_fastdl_copy
	if [ "${shortname}" == "gmod" ]; then
		fn_fastdl_gmod_dl_enforcer
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
		done < "${fastdlclientlist}"
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
	if [ -s "${fastdlcompresslist}" ]; then
		fastdlthreads="$(nproc)"
		fn_print "compressing ${compressfiles} files using ${fastdlthreads} threads"
		xargs -0 -r -n 1 -P "${fastdlthreads}" bzip2 -f < "${fastdlcompresslist}"
		compressexitcode=$?
		while IFS=$'\t' read -r fastdlmode fastdlrelpath fastdlfile; do
			if [ "${fastdlmode}" == "compress" ]; then
				filetocompress="${fastdldir}/${fastdlrelpath}"
				if [ -f "${filetocompress}.bz2" ] && [ ! -f "${filetocompress}" ]; then
					fn_script_log_pass "Compressing ${filetocompress}"
				else
					fn_script_log_fail "Compressing ${filetocompress}"
				fi
			fi
		done < "${fastdlupdatelist}"
		if [ "${compressexitcode}" -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Compressing files"
			exitcode=1
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Compressing files"
		fi
	fi
}

# Saves the list of files written to the fastdl directory.
fn_fastdl_record() {
	fn_print "saving Fastdl file record ${fastdlrecord}"
	mkdir -p "${datadir}" && mv -f "${fastdlnewrecord}" "${fastdlrecord}"
	exitcode=$?
	if [ "${exitcode}" -ne 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fail "Saving Fastdl file record ${fastdlrecord}"
		core_exit.sh
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "Saving Fastdl file record ${fastdlrecord}"
	fi
}

check.sh
# Run functions.
fn_fastdl_preview
if [ "${fastdlrebuild}" == "on" ]; then
	fn_clear_old_fastdl
fi
fn_fastdl_dirs
fn_fastdl_build
if [ "${engine}" == "source" ]; then
	fn_fastdl_bzip2
fi
fn_fastdl_record
rm -f "${fastdlfilelist:?}" "${fastdlduplicatelist:?}" "${fastdlnewrecord:?}" "${fastdlclientlist:?}" "${fastdlupdatelist:?}" "${fastdlremovelist:?}" "${fastdlcompresslist:?}"
# Finished message.
fn_print_nl "Fastdl files are located in:"
fn_print_nl "${fastdldir}"
fn_print_nl "Fastdl completed"
fn_script_log_info "Fastdl completed"

core_exit.sh

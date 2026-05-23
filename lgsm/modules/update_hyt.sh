#!/bin/bash
# LinuxGSM update_hyt.sh module
# Author: Andrew dos Santos
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of Hytale servers.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_hyt_downloader_arch() {
	case "${arch}" in
		x86_64 | amd64)
			hytaledownloaderfile="hytale-downloader-linux-amd64"
			;;
		aarch64 | arm64)
			fn_print_failure "Hytale supports arm64 servers, but the official downloader archive currently used by LinuxGSM does not include a Linux arm64 downloader."
			fn_script_log_fail "Unsupported Hytale downloader architecture: ${arch}"
			core_exit.sh
			;;
		*)
			fn_print_failure "Unknown or unsupported hytale-downloader architecture: ${arch}"
			fn_script_log_fail "Unknown or unsupported hytale-downloader architecture: ${arch}"
			core_exit.sh
			;;
	esac
	hytaledownloader="${serverfiles}/${hytaledownloaderfile}"
}

fn_update_downloader() {
	fn_update_hyt_downloader_arch
	if [ ! -f "${hytaledownloader}" ] || [ "${forceupdate}" == "1" ]; then
		fn_fetch_file "https://downloader.hytale.com/hytale-downloader.zip" "" "" "" "${tmpdir}" "hytale-downloader.zip" "nochmodx" "norun" "forcedl" "nohash"
		echo -en "extracting hytale-downloader..."
		unzip -oq "${tmpdir}/hytale-downloader.zip" "${hytaledownloaderfile}" "QUICKSTART.md" -d "${serverfiles}"
		exitcode=$?
		if [ "${exitcode}" -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Extracting hytale-downloader"
			core_exit.sh
		else
			chmod +x "${hytaledownloader}"
			fn_print_ok_eol_nl
			fn_script_log_pass "Extracting hytale-downloader"
		fi
	fi
}

fn_update_hyt_patchline_args() {
	hytalepatchline="${hytalepatchline:-release}"
	hytalepatchlineargs=()
	if [ "${hytalepatchline}" != "release" ]; then
		hytalepatchlineargs=(-patchline "${hytalepatchline}")
	fi
}

fn_update_extract() {
	extractdir="${tmpdir}/hytale-game"
	rm -rf "${extractdir:?}"
	mkdir -p "${extractdir}"
	echo -en "extracting ${remotebuildfilename}..."
	unzip -oq "${tmpdir}/${remotebuildfilename}" -d "${extractdir}"
	exitcode=$?
	if [ "${exitcode}" -ne 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fail "Extracting ${remotebuildfilename}"
		core_exit.sh
	fi

	if [ -d "${extractdir}/game/Server" ]; then
		extractedroot="${extractdir}/game"
	else
		extractedroot="${extractdir}"
	fi

	mkdir -p "${serverfiles}"
	if [ "${firstcommandname}" == "INSTALL" ]; then
		cp -a "${extractedroot}/." "${serverfiles}/"
	else
		for item in "${extractedroot}"/*; do
			[ -e "${item}" ] || continue
			itemname="$(basename "${item}")"
			case "${itemname}" in
				Server | .hytale-downloader-credentials.json)
					continue
					;;
				jvm.options)
					if [ -f "${serverfiles}/jvm.options" ]; then
						continue
					fi
					;;
			esac
			cp -a "${item}" "${serverfiles}/"
		done
		mkdir -p "${serverfiles}/Server"
		for item in "${extractedroot}/Server"/*; do
			[ -e "${item}" ] || continue
			itemname="$(basename "${item}")"
			case "${itemname}" in
				backups | bans.json | config.json | logs | mods | permissions.json | universe | whitelist.json)
					continue
					;;
			esac
			cp -a "${item}" "${serverfiles}/Server/"
		done
	fi
	[ -f "${serverfiles}/start.sh" ] && chmod +x "${serverfiles}/start.sh"
	fn_print_ok_eol_nl
	fn_script_log_pass "Extracting ${remotebuildfilename}"
	rm -rf "${extractdir:?}"
}

fn_update_dl() {
	fn_update_downloader
	fn_update_hyt_patchline_args
	remotebuildfilename="hytale-server-${remotebuild:-latest}.zip"
	echo -e "downloading file [ ${italic}${remotebuildfilename}${default} ]"
	fn_sleep_time
	cd "${serverfiles}" || exit
	"${hytaledownloader}" -download-path "${tmpdir}/${remotebuildfilename}" "${hytalepatchlineargs[@]}" -skip-update-check
	exitcode=$?
	if [ "${exitcode}" -ne 0 ]; then
		fn_print_failure_nl "Downloading ${remotebuildfilename}"
		fn_script_log_fail "Downloading ${remotebuildfilename}"
		core_exit.sh
	fi
	fn_update_extract
	if [ -n "${remotebuild}" ]; then
		echo "${remotebuild}" > "${localbuildfile}"
	fi
	fn_clear_tmp
}

fn_update_hyt_check_localbuild_tracking() {
	if [ -f "${localbuildfile}" ] && [ -f "${serverfiles}/Server/HytaleServer.jar" ] && [ "${serverfiles}/Server/HytaleServer.jar" -nt "${localbuildfile}" ]; then
		fn_print_warn_nl "Hytale server files are newer than LinuxGSM build tracking"
		echo -e "* Hytale may have updated itself outside LinuxGSM."
		echo -e "* Run ./${selfname} update to refresh LinuxGSM version tracking."
		fn_script_log_warn "Hytale server files are newer than LinuxGSM build tracking"
	fi
}

fn_update_localbuild() {
	fn_print_dots "Checking local build: ${remotelocation}"
	if [ -f "${localbuildfile}" ]; then
		localbuild="$(cat "${localbuildfile}")"
	fi
	if [ -z "${localbuild}" ]; then
		fn_print_error "Checking local build: ${remotelocation}: missing local build info"
		fn_script_log_error "Missing local build info"
		fn_script_log_error "Set localbuild to 0"
		localbuild="0"
	else
		fn_print_ok "Checking local build: ${remotelocation}"
		fn_script_log_pass "Checking local build"
		fn_update_hyt_check_localbuild_tracking
	fi
}

fn_update_remotebuild() {
	fn_update_downloader
	fn_update_hyt_patchline_args
	cd "${serverfiles}" || exit
	remotebuildresponsefile="${tmpdir}/hytale-print-version-response.txt"
	rm -f "${remotebuildresponsefile}"
	"${hytaledownloader}" -print-version "${hytalepatchlineargs[@]}" -skip-update-check 2>&1 | tee "${remotebuildresponsefile}"
	exitcode=${PIPESTATUS[0]}
	remotebuildresponse="$(cat "${remotebuildresponsefile}")"
	if [ -f "${lgsmlog}" ]; then
		cat "${remotebuildresponsefile}" >> "${lgsmlog}"
	fi
	remotebuild=$(echo "${remotebuildresponse}" | grep -Eo "[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[A-Za-z0-9]+" | tail -1)
	if [ -z "${remotebuild}" ]; then
		remotebuild=$(echo "${remotebuildresponse}" | tail -1)
	fi

	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		if [ "${exitcode}" -ne 0 ] || [ -z "${remotebuild}" ] || [ "${remotebuild}" == "null" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fail "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
			fn_script_log_pass "Checking remote build"
		fi
	else
		if [ "${exitcode}" -ne 0 ] || [ -z "${remotebuild}" ] || [ "${remotebuild}" == "null" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fail "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_compare() {
	fn_print_dots "Checking for update: ${remotelocation}"
	if [ "${localbuild}" != "${remotebuild}" ] || [ "${forceupdate}" == "1" ]; then
		date '+%s' > "${lockdir:?}/update.lock"
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		fn_print "\n"
		fn_print_nl "${bold}${underline}Update${default} available"
		fn_print_nl "* Local build: ${red}${localbuild}${default}"
		fn_print_nl "* Remote build: ${green}${remotebuild}${default}"
		fn_print_nl "* Patchline: ${hytalepatchline}"
		fn_print "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		fn_script_log_info "Patchline: ${hytalepatchline}"

		if [ "${commandname}" == "UPDATE" ]; then
			date +%s > "${lockdir:?}/last-updated.lock"
			unset updateonstart
			check_status.sh
			if [ "${status}" == "0" ]; then
				fn_update_dl
			else
				fn_print_restart_warning
				exitbypass=1
				command_stop.sh
				fn_firstcommand_reset
				exitbypass=1
				fn_update_dl
				exitbypass=1
				command_start.sh
				fn_firstcommand_reset
			fi
			unset exitbypass
			alert="update"
		elif [ "${commandname}" == "CHECK-UPDATE" ]; then
			alert="check-update"
		fi
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		fn_print "\n"
		fn_print_nl "${bold}${underline}No update${default} available"
		fn_print_nl "* Local build: ${green}${localbuild}${default}"
		fn_print_nl "* Remote build: ${green}${remotebuild}${default}"
		fn_print_nl "* Patchline: ${hytalepatchline}"
		fn_print "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		fn_script_log_info "Patchline: ${hytalepatchline}"
	fi
}

info_distro.sh

localbuildfile="${datadir}/${selfname}-hytale-version"
remotelocation="hytale.com"

if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_remotebuild
	fn_update_dl
else
	fn_print_dots "Checking for update"
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_localbuild
	fn_update_remotebuild
	fn_update_compare
fi

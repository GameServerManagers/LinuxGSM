#!/bin/bash
# LinuxGSM update_bfe.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of Battlefront Eternal servers.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_node_remote() {
	# Gets the latest Node.js 24 build and the installed version.
	nodeurl="https://nodejs.org/dist/latest-v24.x"
	nodeshasums=$(curl -s "${nodeurl}/SHASUMS256.txt")
	nodefilename=$(echo "${nodeshasums}" | grep -o "node-v[0-9.]*-linux-${nodearch}.tar.xz" | head -1)
	nodeversion=$(echo "${nodefilename}" | cut -d '-' -f 2)
	nodehash=$(echo "${nodeshasums}" | grep " ${nodefilename}$" | awk '{print $1}')
	if [ -z "${nodefilename}" ] || [ -z "${nodehash}" ]; then
		fn_print_failure_nl "Unable to get Node.js build"
		fn_script_log_fail "Unable to get Node.js build"
		core_exit.sh
	fi
	nodelocalversion=""
	if [ -x "${serverfiles}/node/bin/node" ]; then
		nodelocalversion=$("${serverfiles}/node/bin/node" --version 2> /dev/null)
	fi
}

fn_update_node_dl() {
	# Installs the Node.js runtime the server runs on.
	fn_fetch_file "${nodeurl}/${nodefilename}" "" "" "" "${tmpdir}" "${nodefilename}" "nochmodx" "norun" "forcedl" "${nodehash}"
	rm -rf "${serverfiles:?}/node.new"
	fn_dl_extract "${tmpdir}" "${nodefilename}" "${serverfiles}/node.new" "${nodefilename%.tar.xz}"
	rm -rf "${serverfiles:?}/node"
	mv "${serverfiles}/node.new" "${serverfiles}/node"
	fn_clear_tmp
}

fn_update_node() {
	fn_update_node_remote
	if [ "${nodelocalversion}" != "${nodeversion}" ]; then
		fn_update_node_dl
	fi
}

fn_update_node_compare() {
	fn_print_dots "Checking for update: nodejs.org"
	fn_update_node_remote
	if [ "${nodelocalversion}" != "${nodeversion}" ]; then
		date '+%s' > "${lockdir:?}/update.lock"
		fn_print_ok_nl "Checking for update: nodejs.org"
		fn_print "\n"
		fn_print_nl "${bold}${underline}Node.js update${default} available"
		fn_print_nl "* Local version: ${red}${nodelocalversion:-none}${default}"
		fn_print_nl "* Remote version: ${green}${nodeversion}${default}"
		fn_print "\n"
		fn_script_log_info "Node.js update available"
		fn_script_log_info "Local version: ${nodelocalversion:-none}"
		fn_script_log_info "Remote version: ${nodeversion}"
		previousbuild="Node.js ${nodelocalversion:-none}"
		localbuild="Node.js ${nodelocalversion:-none}"
		remotebuild="Node.js ${nodeversion}"
		if [ "${commandname}" == "UPDATE" ]; then
			unset updateonstart
			fn_update_apply fn_update_node_dl
			localbuild="${remotebuild}"
			alert="update"
		elif [ "${commandname}" == "CHECK-UPDATE" ]; then
			alert="check-update"
		fi
		alert.sh
	else
		fn_print_ok_nl "Checking for update: nodejs.org"
		fn_print "\n"
		fn_print_nl "${bold}${underline}No Node.js update${default} available"
		fn_print_nl "* Local version: ${green}${nodelocalversion}${default}"
		fn_print_nl "* Remote version: ${green}${nodeversion}${default}"
		fn_print "\n"
		fn_script_log_info "No Node.js update available"
		fn_script_log_info "Local version: ${nodelocalversion}"
		fn_script_log_info "Remote version: ${nodeversion}"
	fi
}

fn_update_prepare() {
	# Prepares the game data from the owned game when the release's tools change.
	datakey=$(jq -r '.files[] | select((.path | startswith("resources/tools/")) or (.path | startswith("resources/toolchain/python/"))) | "\(.path) \(.sha256)"' "${serverfiles}/bfe/bfe-tree.json" | LC_ALL=C sort)
	datakey=$(printf '%s' "${datakey}" | sha256sum | cut -c 1-32)
	if [ -f "${serverfiles}/bfe-data/.lgsm-data-key" ] && [ "$(cat "${serverfiles}/bfe-data/.lgsm-data-key")" == "${datakey}" ]; then
		return
	fi
	if [ ! -d "${serverfiles}/GameData" ]; then
		fn_print_failure_nl "Game data not found: ${serverfiles}/GameData"
		fn_script_log_fail "Game data not found: ${serverfiles}/GameData"
		echo -e "* The Steam account must own STAR WARS Battlefront (Classic, 2004)."
		echo -e "* Run ./${selfname} validate to download it."
		core_exit.sh
	fi
	preparelog="${lgsmlogdir}/${selfname}-prepare.log"
	echo -e "preparing game data, this can take several minutes"
	fn_script_log_info "Preparing game data ${datakey}"
	rm -rf "${serverfiles:?}/bfe-data.new"
	mkdir -p "${serverfiles}/bfe-data.new"
	(
		cd "${serverfiles}/bfe/tools" || exit 1
		env -i PATH="${serverfiles}/bfe/toolchain/bin:/usr/local/bin:/usr/bin:/bin" HOME="${serverfiles}/bfe-data.new" LANG="C.UTF-8" BFE_GAME_DIR="${serverfiles}" BFE_CONTENT_DIR="${serverfiles}/bfe-data.new" KTX2_ENCODER="off" PYTHONUNBUFFERED="1" PYTHONDONTWRITEBYTECODE="1" PYTHONIOENCODING="utf-8" "${serverfiles}/bfe/toolchain/python/bin/python3" -u prepare.py --core-only --jobs "$(nproc)" > "${preparelog}" 2>&1
	)
	exitcode=$?
	if [ "${exitcode}" -ne 0 ]; then
		fn_print_failure_nl "Preparing game data"
		fn_script_log_fail "Preparing game data, see ${preparelog}"
		tail -n 20 "${preparelog}"
		rm -rf "${serverfiles:?}/bfe-data.new"
		core_exit.sh
	fi
	echo "${datakey}" > "${serverfiles}/bfe-data.new/.lgsm-data-key"
	rm -rf "${serverfiles:?}/bfe-data"
	mv "${serverfiles}/bfe-data.new" "${serverfiles}/bfe-data"
	fn_print_ok_nl "Preparing game data"
	fn_script_log_pass "Preparing game data"
}

fn_update_dl() {
	# Download and extract files to tmpdir.
	fn_update_node
	fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "${remotebuildfilename}" "nochmodx" "norun" "forcedl" "${remotebuildhash}"
	rm -rf "${serverfiles:?}/bfe"
	fn_dl_extract "${tmpdir}" "${remotebuildfilename}" "${serverfiles}/bfe"
	fn_update_prepare
	echo "${remotebuild}" > "${localbuildfile}"
	fn_clear_tmp
}

fn_update_localbuild() {
	# Gets local build info.
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
	fi
}

fn_update_remotebuild() {
	# Gets remote build info.
	apiurl="https://get.battlefronteternal.com/downloads/latest"
	remotebuildresponse=$(curl -s "${apiurl}/SHA256SUMS")
	remotebuildfilename=$(echo "${remotebuildresponse}" | grep -o "battlefront-eternal-server_[^ ]*_linux-${archivearch}\.tar\.xz" | head -1)
	remotebuildhash=$(echo "${remotebuildresponse}" | grep " ${remotebuildfilename}$" | awk '{print $1}')
	remotebuild=$(echo "${remotebuildfilename}" | cut -d '_' -f 2)
	remotebuildurl="${apiurl}/${remotebuildfilename}"
	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ] || [ -z "${remotebuildhash}" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fail "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
			fn_script_log_pass "Checking remote build"
		fi
	else
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ] || [ -z "${remotebuildhash}" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fail "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_compare() {
	fn_print_dots "Checking for update: ${remotelocation}"
	# Update has been found or force update.
	if [ "${localbuild}" != "${remotebuild}" ] || [ "${forceupdate}" == "1" ]; then
		# Create update lockfile.
		date '+%s' > "${lockdir:?}/update.lock"
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		fn_print "\n"
		fn_print_nl "${bold}${underline}Update${default} available"
		fn_print_nl "* Local build: ${red}${localbuild}${default}"
		fn_print_nl "* Remote build: ${green}${remotebuild}${default}"
		if [ -f "${rootdir}/.dev-debug" ]; then
			fn_print_nl "Remote build info"
			fn_print_nl "* apiurl: ${apiurl}"
			fn_print_nl "* remotebuildfilename: ${remotebuildfilename}"
			fn_print_nl "* remotebuildurl: ${remotebuildurl}"
			fn_print_nl "* remotebuild: ${remotebuild}"
		fi
		fn_print "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		fn_script_log_info "${localbuild} > ${remotebuild}"

		if [ "${commandname}" == "UPDATE" ]; then
			unset updateonstart
			fn_update_apply fn_update_dl
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
		fn_print "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		if [ -f "${rootdir}/.dev-debug" ]; then
			fn_print_nl "Remote build info"
			fn_print_nl "* apiurl: ${apiurl}"
			fn_print_nl "* remotebuildfilename: ${remotebuildfilename}"
			fn_print_nl "* remotebuildurl: ${remotebuildurl}"
			fn_print_nl "* remotebuild: ${remotebuild}"
		fi
	fi
}

if [ "$(uname -m)" == "aarch64" ]; then
	archivearch="arm64"
	nodearch="arm64"
else
	archivearch="amd64"
	nodearch="x64"
fi

localbuildfile="${datadir}/${selfname}-bfe-version"
# The location where the builds are checked and downloaded.
remotelocation="get.battlefronteternal.com"

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
	if [ "${localbuild}" == "${remotebuild}" ] && [ "${forceupdate}" != "1" ]; then
		fn_update_node_compare
	fi
fi

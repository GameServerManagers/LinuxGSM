#!/bin/bash
# LinuxGSM workshop_core.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Downloads and installs Steam Workshop mods for game servers that cannot download them.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Installed mods are named ${workshopprefix}<id> in the directory the game loads them from.
if [ "${shortname}" == "squad" ]; then
	workshopdir="${systemdir}/Plugins/Mods"
	workshopprefix=""
else
	workshopdir="${serverfiles}/workshop"
	workshopprefix="@"
fi
workshopdldir="${tmpdir}/workshop"
workshopmodlist="${datadir}/${selfname}-workshop.txt"
workshopapi="https://api.steampowered.com/ISteamRemoteStorage"
workshopapimax="100"
workshopretries="5"

# Converts workshopmods into an ordered list of IDs. Accepts space, comma or semicolon separators.
fn_workshop_config_ids() {
	workshopconfigids=()
	local id
	for id in ${workshopmods//[,;]/ }; do
		if [[ "${id}" =~ ^[0-9]+$ ]]; then
			workshopconfigids+=("${id}")
		else
			fn_print_warn_nl "Ignoring invalid Workshop ID: ${id}"
			fn_script_log_warn "Ignoring invalid Workshop ID: ${id}"
		fi
	done
}

# Queries the Steam Web API. Usage: fn_workshop_api <GetCollectionDetails|GetPublishedFileDetails> <id>...
fn_workshop_api() {
	local method="$1"
	shift
	local countparam="itemcount"
	if [ "${method}" == "GetCollectionDetails" ]; then
		countparam="collectioncount"
	fi
	local postdata=("--data-urlencode" "${countparam}=$#")
	local index=0
	local id
	for id in "$@"; do
		postdata+=("--data-urlencode" "publishedfileids[${index}]=${id}")
		index=$((index + 1))
	done
	curl -sSL --connect-timeout 10 --max-time 60 "${postdata[@]}" "${workshopapi}/${method}/v1/"
}

# Records which IDs are collections and their children, in batches.
fn_workshop_get_collections() {
	local ids=("$@")
	local start response
	for ((start = 0; start < ${#ids[@]}; start += workshopapimax)); do
		if ! response="$(fn_workshop_api GetCollectionDetails "${ids[@]:start:workshopapimax}")" || ! jq -e '.response' <<< "${response}" > /dev/null 2>&1; then
			fn_print_fail_nl "Checking for update: ${remotelocation}: Unable to get collection details from Steam"
			fn_script_log_fail "Checking for update: ${remotelocation}: Unable to get collection details from Steam"
			core_exit.sh
		fi
		local id result children
		while IFS=$'\t' read -r id result children; do
			workshopchecked["${id}"]=1
			if [ "${result}" == "1" ]; then
				workshopchildren["${id}"]="${children}"
			fi
		done < <(jq -r '.response.collectiondetails[] | [.publishedfileid, (.result | tostring), ([.children[]? | "\(.publishedfileid):\(.filetype)"] | join(" "))] | @tsv' <<< "${response}")
	done
}

# Adds an ID to workshopitems, expanding collections in their sort order.
fn_workshop_expand() {
	local id="$1"
	local depth="$2"
	if [ -n "${workshopseen[${id}]}" ]; then
		return
	fi
	workshopseen["${id}"]=1
	if [ -n "${workshopchildren[${id}]+set}" ]; then
		if [ "${depth}" -gt 3 ]; then
			fn_print_warn_nl "Skipping Workshop collection ${id}: collections are nested too deeply"
			fn_script_log_warn "Skipping Workshop collection ${id}: collections are nested too deeply"
			return
		fi
		local child
		for child in ${workshopchildren[${id}]}; do
			fn_workshop_expand "${child%%:*}" $((depth + 1))
		done
	else
		workshopitems+=("${id}")
	fi
}

# Builds workshopitems: the ordered list of Workshop items to install, with collections expanded.
fn_workshop_resolve() {
	declare -gA workshopchecked=()
	declare -gA workshopchildren=()
	declare -gA workshopseen=()
	workshopitems=()
	fn_workshop_config_ids
	if [ "${#workshopconfigids[@]}" -eq 0 ]; then
		return
	fi
	local tocheck=("${workshopconfigids[@]}")
	local round id child
	for ((round = 0; round < 4 && ${#tocheck[@]} > 0; round++)); do
		fn_workshop_get_collections "${tocheck[@]}"
		local nested=()
		for id in "${tocheck[@]}"; do
			for child in ${workshopchildren[${id}]}; do
				if [ "${child##*:}" == "2" ] && [ -z "${workshopchecked[${child%%:*}]}" ]; then
					nested+=("${child%%:*}")
				fi
			done
		done
		tocheck=("${nested[@]}")
	done
	for id in "${workshopconfigids[@]}"; do
		fn_workshop_expand "${id}" 0
	done
}

# Gets title, game appid and last updated time for each item in workshopitems.
fn_workshop_get_details() {
	declare -gA workshoptitle=()
	declare -gA workshopappid=()
	declare -gA workshoptimeupdated=()
	local validitems=()
	local start response
	for ((start = 0; start < ${#workshopitems[@]}; start += workshopapimax)); do
		if ! response="$(fn_workshop_api GetPublishedFileDetails "${workshopitems[@]:start:workshopapimax}")" || ! jq -e '.response' <<< "${response}" > /dev/null 2>&1; then
			fn_print_fail_nl "Checking for update: ${remotelocation}: Unable to get Workshop item details from Steam"
			fn_script_log_fail "Checking for update: ${remotelocation}: Unable to get Workshop item details from Steam"
			core_exit.sh
		fi
		local id result appid timeupdated title
		while IFS=$'\t' read -r id result appid timeupdated title; do
			if [ "${result}" != "1" ] || [ -z "${timeupdated}" ]; then
				fn_print_warn_nl "Skipping Workshop item ${id}: not found, or not public"
				fn_script_log_warn "Skipping Workshop item ${id}: not found, or not public"
				continue
			fi
			workshoptitle["${id}"]="${title}"
			workshopappid["${id}"]="${appid}"
			workshoptimeupdated["${id}"]="${timeupdated}"
		done < <(jq -r '.response.publishedfiledetails[] | [.publishedfileid, (.result | tostring), (.consumer_app_id // "" | tostring), (.time_updated // "" | tostring), (.title // "" | gsub("[\t\n\r]"; " "))] | @tsv' <<< "${response}")
	done
	local item
	for item in "${workshopitems[@]}"; do
		if [ -n "${workshoptimeupdated[${item}]}" ]; then
			validitems+=("${item}")
		fi
	done
	workshopitems=("${validitems[@]}")
}

# Reads a value from an installed mod's state file. Usage: fn_workshop_state <id> <key>
fn_workshop_state() {
	local statefile="${workshopdir}/${workshopprefix}${1}/.lgsm-workshop"
	if [ -f "${statefile}" ]; then
		sed -n "s/^${2}=//p" "${statefile}"
	fi
}

# Works out which mods need downloading and which installed mods are no longer used.
fn_workshop_compare() {
	workshopupdates=()
	workshopremovals=()
	local item
	for item in "${workshopitems[@]}"; do
		if [ "$(fn_workshop_state "${item}" timeupdated)" != "${workshoptimeupdated[${item}]}" ]; then
			workshopupdates+=("${item}")
		fi
	done
	if [ -d "${workshopdir}" ]; then
		# Mods used by any instance sharing these serverfiles are kept.
		local inuse=" ${workshopitems[*]} "
		local listfile
		for listfile in "${datadir}"/*-workshop.txt; do
			if [ -f "${listfile}" ] && [ "${listfile}" != "${workshopmodlist}" ]; then
				inuse+="$(grep -v '^#' "${listfile}" | tr '\n' ' ') "
			fi
		done
		local statefile moddir
		for statefile in "${workshopdir}"/*/.lgsm-workshop; do
			if [ -f "${statefile}" ]; then
				moddir="${statefile%/*}"
				moddir="${moddir##*/}"
				item="${moddir#"${workshopprefix}"}"
				if [[ "${inuse}" != *" ${item} "* ]]; then
					workshopremovals+=("${item}")
				fi
			fi
		done
	fi
}

# Downloads Workshop items with a single SteamCMD login. Failed items are retried.
fn_workshop_download() {
	local pending=("$@")
	local attempt=0
	local item params
	steamcmdlog="${lgsmlogdir}/${selfname}-steamcmd.log"
	rm -rf "${workshopdldir:?}"
	mkdir -p "${workshopdldir}"
	if [ -d "${steamcmddir}" ]; then
		cd "${steamcmddir}" || exit
	fi
	unbuffercommand=()
	if [ "$(command -v unbuffer 2> /dev/null)" ]; then
		unbuffercommand=("unbuffer")
	fi
	while [ "${#pending[@]}" -gt 0 ] && [ "${attempt}" -lt "${workshopretries}" ]; do
		attempt=$((attempt + 1))
		params=(+force_install_dir "${workshopdldir}" +login "${steamuser}" "${steampass}")
		for item in "${pending[@]}"; do
			params+=(+workshop_download_item "${workshopappid[${item}]}" "${item}")
		done
		params+=(+quit)
		rm -f "${steamcmdlog:?}"
		"${unbuffercommand[@]}" "${steamcmdcommand}" "${params[@]}" | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"

		if grep -q "FAILED (" "${steamcmdlog}" || grep -q "Two-factor code mismatch" "${steamcmdlog}"; then
			fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: Steam login failed"
			fn_print_nl "Check steamuser and steampass in ${configdirserver}"
			fn_script_log_fail "${commandaction} ${selfname}: ${remotelocation}: Steam login failed"
			core_exit.sh
		fi

		local failed=()
		for item in "${pending[@]}"; do
			if [ -z "$(find "${workshopdldir}/steamapps/workshop/content/${workshopappid[${item}]}/${item}" -mindepth 1 -print -quit 2> /dev/null)" ]; then
				failed+=("${item}")
			fi
		done
		pending=("${failed[@]}")
		if [ "${#pending[@]}" -gt 0 ] && [ "${attempt}" -lt "${workshopretries}" ]; then
			fn_print_error2_nl "${commandaction} ${selfname}: ${remotelocation}: ${#pending[@]} item(s) did not download, retrying"
			fn_script_log_error "${commandaction} ${selfname}: ${remotelocation}: ${#pending[@]} item(s) did not download, retrying"
		fi
	done
	workshopfailed=("${pending[@]}")
	if [ "${#workshopfailed[@]}" -gt 0 ]; then
		fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: ${#workshopfailed[@]} item(s) failed to download"
		for item in "${workshopfailed[@]}"; do
			fn_print_nl "* ${workshoptitle[${item}]} (${item})"
			fn_script_log_fail "${commandaction} ${selfname}: ${remotelocation}: ${workshoptitle[${item}]} (${item}) failed to download"
		done
		fn_print_nl "The Steam account must own the game for its Workshop items to download"
	fi
}

# Renames files and directories in a mod to lowercase, deepest first.
fn_workshop_lowercase() {
	local path name lower
	while IFS= read -r -d '' path; do
		name="${path##*/}"
		lower="${name,,}"
		if [ -e "${path%/*}/${lower}" ]; then
			fn_script_log_warn "Lowercase name already exists, not renaming: ${path}"
		else
			mv "${path}" "${path%/*}/${lower}"
		fi
	done < <(find "$1" -mindepth 1 -depth -name '*[[:upper:]]*' -print0)
}

# Removes the BattlEye keys a mod installed, unless another installed mod also uses them.
fn_workshop_remove_keys() {
	local item="$1"
	local key statefile
	for key in $(fn_workshop_state "${item}" keys); do
		local shared=""
		for statefile in "${workshopdir}"/*/.lgsm-workshop; do
			if [ "${statefile}" != "${workshopdir}/${workshopprefix}${item}/.lgsm-workshop" ] && [[ " $(sed -n 's/^keys=//p' "${statefile}" 2> /dev/null) " == *" ${key} "* ]]; then
				shared=1
			fi
		done
		if [ -z "${shared}" ]; then
			rm -f "${serverfiles:?}/keys/${key}"
		fi
	done
}

# Removes the links a mod added to the Starbound mods directory.
fn_workshop_remove_links() {
	local link
	for link in $(fn_workshop_state "$1" links); do
		rm -f "${serverfiles:?}/mods/${link}"
	done
}

# Moves a downloaded item into the game's mod directory and prepares it for the game.
fn_workshop_install() {
	local item="$1"
	local src="${workshopdldir}/steamapps/workshop/content/${workshopappid[${item}]}/${item}"
	local dst="${workshopdir}/${workshopprefix}${item}"
	local keys=()
	local links=()
	local key pak
	fn_print_dots "Installing ${workshoptitle[${item}]} (${item})"
	if [ -d "${dst}" ]; then
		fn_workshop_remove_keys "${item}"
		fn_workshop_remove_links "${item}"
		rm -rf "${dst:?}"
	fi
	mkdir -p "${workshopdir}"
	if ! mv "${src}" "${dst}"; then
		fn_print_fail_nl "Installing ${workshoptitle[${item}]} (${item})"
		fn_script_log_fail "Installing ${workshoptitle[${item}]} (${item})"
		core_exit.sh
	fi
	if [ "${shortname}" == "arma3" ] || [ "${shortname}" == "dayz" ]; then
		fn_workshop_lowercase "${dst}"
		mkdir -p "${serverfiles}/keys"
		while IFS= read -r -d '' key; do
			cp -f "${key}" "${serverfiles}/keys/"
			keys+=("${key##*/}")
		done < <(find "${dst}" -type f -name '*.bikey' -print0)
	elif [ "${shortname}" == "sb" ]; then
		mkdir -p "${serverfiles}/mods"
		while IFS= read -r -d '' pak; do
			ln -sfn "../workshop/${workshopprefix}${item}/${pak##*/}" "${serverfiles}/mods/workshop-${item}-${pak##*/}"
			links+=("workshop-${item}-${pak##*/}")
		done < <(find "${dst}" -maxdepth 1 -type f -name '*.pak' -print0)
	fi
	{
		echo "title=${workshoptitle[${item}]}"
		echo "timeupdated=${workshoptimeupdated[${item}]}"
		echo "keys=${keys[*]}"
		echo "links=${links[*]}"
	} > "${dst}/.lgsm-workshop"
	fn_print_ok_nl "Installing ${workshoptitle[${item}]} (${item})"
	fn_script_log_pass "Installing ${workshoptitle[${item}]} (${item})"
}

# Removes an installed mod that is no longer in workshopmods.
fn_workshop_remove() {
	local item="$1"
	local title
	title="$(fn_workshop_state "${item}" title)"
	fn_print_dots "Removing ${title} (${item})"
	fn_workshop_remove_keys "${item}"
	fn_workshop_remove_links "${item}"
	rm -rf "${workshopdir:?}/${workshopprefix}${item}"
	fn_print_ok_nl "Removing ${title} (${item})"
	fn_script_log_pass "Removing ${title} (${item})"
}

# Installs downloaded items and removes unused ones. Downloads happen first, so the server only stops for this step.
fn_workshop_apply() {
	local item
	for item in "${workshopinstalls[@]}"; do
		fn_workshop_install "${item}"
	done
	for item in "${workshopremovals[@]}"; do
		fn_workshop_remove "${item}"
	done
	rm -rf "${workshopdldir:?}"
}

# Saves the resolved mod order so start can build the mod list without querying Steam.
fn_workshop_save_list() {
	{
		echo "# workshopmods=${workshopmods}"
		printf '%s\n' "${workshopitems[@]}"
	} > "${workshopmodlist}"
}

# Checks for Workshop mod updates and, for update commands, applies them.
fn_workshop_update() {
	remotelocation="Steam Workshop"
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_workshop_resolve
	if [ "${#workshopitems[@]}" -gt 0 ]; then
		fn_workshop_get_details
	fi
	fn_workshop_compare
	fn_print_ok_nl "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"

	local item
	if [ "${#workshopupdates[@]}" -eq 0 ] && [ "${#workshopremovals[@]}" -eq 0 ]; then
		fn_print "\n"
		fn_print_nl "${bold}${underline}No update${default} available"
		fn_print_nl "* Workshop mods: ${#workshopitems[@]}"
		fn_print "\n"
		fn_script_log_info "No update available: ${remotelocation}"
		if [ "${commandname}" != "CHECK-UPDATE" ]; then
			if [ "${#workshopitems[@]}" -eq 0 ]; then
				rm -f "${workshopmodlist}"
			else
				fn_workshop_save_list
			fi
		fi
		return
	fi

	fn_print "\n"
	fn_print_nl "${bold}${underline}Update${default} available"
	for item in "${workshopupdates[@]}"; do
		if [ -d "${workshopdir}/${workshopprefix}${item}" ]; then
			fn_print_nl "* Update: ${workshoptitle[${item}]} (${item})"
		else
			fn_print_nl "* Install: ${workshoptitle[${item}]} (${item})"
		fi
		fn_script_log_info "Update available: ${workshoptitle[${item}]} (${item})"
	done
	for item in "${workshopremovals[@]}"; do
		fn_print_nl "* Remove: $(fn_workshop_state "${item}" title) (${item})"
		fn_script_log_info "Remove: $(fn_workshop_state "${item}" title) (${item})"
	done
	fn_print "\n"

	if [ "${commandname}" == "CHECK-UPDATE" ]; then
		return
	fi

	fn_workshop_save_list
	date '+%s' > "${lockdir:?}/update.lock"
	workshopinstalls=()
	workshopfailed=()
	if [ "${#workshopupdates[@]}" -gt 0 ]; then
		fn_print_start_nl "${remotelocation}"
		fn_workshop_download "${workshopupdates[@]}"
		for item in "${workshopupdates[@]}"; do
			if [[ " ${workshopfailed[*]} " != *" ${item} "* ]]; then
				workshopinstalls+=("${item}")
			fi
		done
	fi
	if [ "${#workshopinstalls[@]}" -eq 0 ] && [ "${#workshopremovals[@]}" -eq 0 ]; then
		rm -rf "${workshopdldir:?}"
		return
	fi

	check_status.sh
	if [ "${status}" == "0" ]; then
		fn_workshop_apply
	else
		fn_print_restart_warning
		exitbypass=1
		command_stop.sh
		fn_firstcommand_reset
		fn_workshop_apply
		exitbypass=1
		command_start.sh
		fn_firstcommand_reset
	fi
	unset exitbypass
}

# Adds installed Workshop mods to the mods start parameter, in workshopmods order.
fn_workshop_mods_startparameters() {
	if [ -n "${workshopmodsadded}" ]; then
		return
	fi
	workshopmodsadded=1
	local items=()
	if [ -f "${workshopmodlist}" ]; then
		mapfile -t items < <(grep -v '^#' "${workshopmodlist}")
		if [ "$(sed -n 's/^# workshopmods=//p' "${workshopmodlist}")" != "${workshopmods}" ]; then
			fn_print_warn_nl "workshopmods has changed. Run ./${selfname} workshop-update to apply it"
			fn_script_log_warn "workshopmods has changed. Run ./${selfname} workshop-update to apply it"
		fi
	else
		fn_workshop_config_ids
		items=("${workshopconfigids[@]}")
	fi
	local workshopmodsparam=""
	local missing=0
	local item
	for item in "${items[@]}"; do
		if [ -d "${workshopdir}/${workshopprefix}${item}" ]; then
			workshopmodsparam+="${workshopmodsparam:+\\;}workshop/${workshopprefix}${item}"
		else
			missing=$((missing + 1))
		fi
	done
	if [ "${missing}" -gt 0 ]; then
		fn_print_warn_nl "${missing} Workshop mod(s) not installed. Run ./${selfname} workshop-update to install them"
		fn_script_log_warn "${missing} Workshop mod(s) not installed"
	fi
	if [ -n "${workshopmodsparam}" ]; then
		mods="${mods:+${mods}\\;}${workshopmodsparam}"
	fi
}

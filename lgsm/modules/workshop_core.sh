#!/bin/bash
# LinuxGSM workshop_core.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Downloads and installs Steam Workshop mods for game servers that cannot download them.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Installed mods are named ${workshopprefix}<id> in the directory the game loads them from.
if [ "${shortname}" == "squad" ] || [ "${shortname}" == "squad44" ]; then
	workshopdir="${systemdir}/Plugins/Mods"
	workshopprefix=""
elif [ "${shortname}" == "ohd" ]; then
	workshopdir="${systemdir}/Mods"
	workshopprefix=""
	workshopflatten=1
elif [ "${shortname}" == "bt" ]; then
	workshopdir="${serverfiles}/LocalMods"
	workshopprefix=""
elif [ "${shortname}" == "hw" ]; then
	workshopdir="${serverfiles}/steamapps/workshop/content/393420"
	workshopprefix=""
	workshopinplace=1
elif [ "${shortname}" == "col" ]; then
	workshopdir="${serverfiles}/gamedata/mods"
	workshopprefix=""
elif [ "${shortname}" == "st" ]; then
	workshopdir="${serverfiles}/mods"
	workshopprefix=""
else
	workshopdir="${serverfiles}/workshop"
	workshopprefix="@"
fi
# Games that load mod files from their own directory get links to the installed files there.
if [ "${shortname}" == "sb" ]; then
	workshoplinkdir="${serverfiles}/mods"
elif [ "${shortname}" == "l4d2" ]; then
	workshoplinkdir="${serverfiles}/left4dead2/addons"
elif [ "${shortname}" == "sol" ]; then
	workshoplinkdir="${serverfiles}"
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

# Prints the directory a Workshop item is installed in, if it is installed.
fn_workshop_moddir() {
	local statefile
	if [ -f "${workshopdir}/${workshopprefix}${1}/.lgsm-workshop" ]; then
		echo "${workshopdir}/${workshopprefix}${1}"
		return
	fi
	for statefile in "${workshopdir}"/*/.lgsm-workshop; do
		if [ -f "${statefile}" ] && grep -qx "id=${1}" "${statefile}"; then
			echo "${statefile%/.lgsm-workshop}"
			return
		fi
	done
}

# Reads a value from an installed mod's state file. Usage: fn_workshop_state <id> <key>
fn_workshop_state() {
	local moddir
	moddir="$(fn_workshop_moddir "${1}")"
	if [ -n "${moddir}" ]; then
		sed -n "s/^${2}=//p" "${moddir}/.lgsm-workshop"
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
				item="$(sed -n 's/^id=//p' "${statefile}")"
				if [ -z "${item}" ]; then
					moddir="${statefile%/*}"
					moddir="${moddir##*/}"
					item="${moddir#"${workshopprefix}"}"
				fi
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
	if [ -n "${workshopinplace}" ]; then
		workshopdlroot="${serverfiles}"
	else
		workshopdlroot="${workshopdldir}"
		rm -rf "${workshopdldir:?}"
		mkdir -p "${workshopdldir}"
	fi
	if [ -d "${steamcmddir}" ]; then
		cd "${steamcmddir}" || exit
	fi
	unbuffercommand=()
	if [ "$(command -v unbuffer 2> /dev/null)" ]; then
		unbuffercommand=("unbuffer")
	fi
	while [ "${#pending[@]}" -gt 0 ] && [ "${attempt}" -lt "${workshopretries}" ]; do
		attempt=$((attempt + 1))
		params=(+force_install_dir "${workshopdlroot}" +login "${steamuser}" "${steampass}")
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
			if [ -z "$(find "${workshopdlroot}/steamapps/workshop/content/${workshopappid[${item}]}/${item}" -mindepth 1 -print -quit 2> /dev/null)" ]; then
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
	local key statefile moddir
	moddir="$(fn_workshop_moddir "${item}")"
	for key in $(fn_workshop_state "${item}" keys); do
		local shared=""
		for statefile in "${workshopdir}"/*/.lgsm-workshop; do
			if [ "${statefile}" != "${moddir}/.lgsm-workshop" ] && [[ " $(sed -n 's/^keys=//p' "${statefile}" 2> /dev/null) " == *" ${key} "* ]]; then
				shared=1
			fi
		done
		if [ -z "${shared}" ]; then
			rm -f "${serverfiles:?}/keys/${key}"
		fi
	done
}

# Removes the links a mod added to the game's mod directory.
fn_workshop_remove_links() {
	local link
	while IFS= read -r link; do
		if [ -n "${link}" ]; then
			rm -f "${workshoplinkdir:?}/${link}"
		fi
	done < <(fn_workshop_state "$1" link)
}

# Moves a downloaded item into the game's mod directory and prepares it for the game.
fn_workshop_install() {
	local item="$1"
	local src="${workshopdlroot}/steamapps/workshop/content/${workshopappid[${item}]}/${item}"
	local dst="${workshopdir}/${workshopprefix}${item}"
	local installed
	local keys=()
	local links=()
	local key pak file rel
	fn_print_dots "Installing ${workshoptitle[${item}]} (${item})"
	installed="$(fn_workshop_moddir "${item}")"
	if [ -n "${installed}" ]; then
		fn_workshop_remove_keys "${item}"
		fn_workshop_remove_links "${item}"
		if [ "${installed}" != "${src}" ]; then
			rm -rf "${installed:?}"
		fi
	fi
	# A mod that is a single plugin folder is installed as that folder, for games that load mods by folder name.
	if [ -n "${workshopflatten}" ]; then
		local subdirs=()
		mapfile -t subdirs < <(find "${src}" -mindepth 1 -maxdepth 1 -type d)
		if [ "${#subdirs[@]}" -eq 1 ] && [ -z "$(find "${src}" -mindepth 1 -maxdepth 1 -type f -print -quit)" ]; then
			dst="${workshopdir}/${subdirs[0]##*/}"
			src="${subdirs[0]}"
		fi
	fi
	if [ "${src}" != "${dst}" ]; then
		if [ -e "${dst}" ]; then
			fn_print_fail_nl "Installing ${workshoptitle[${item}]} (${item}): ${dst} already exists"
			fn_script_log_fail "Installing ${workshoptitle[${item}]} (${item}): ${dst} already exists"
			return
		fi
		mkdir -p "${workshopdir}"
		if ! mv "${src}" "${dst}"; then
			fn_print_fail_nl "Installing ${workshoptitle[${item}]} (${item})"
			fn_script_log_fail "Installing ${workshoptitle[${item}]} (${item})"
			core_exit.sh
		fi
	fi
	if [ "${shortname}" == "arma3" ] || [ "${shortname}" == "dayz" ]; then
		fn_workshop_lowercase "${dst}"
		mkdir -p "${serverfiles}/keys"
		while IFS= read -r -d '' key; do
			cp -f "${key}" "${serverfiles}/keys/"
			keys+=("${key##*/}")
		done < <(find "${dst}" -type f -name '*.bikey' -print0)
	elif [ "${shortname}" == "sb" ]; then
		mkdir -p "${workshoplinkdir}"
		while IFS= read -r -d '' pak; do
			ln -srfn "${pak}" "${workshoplinkdir}/workshop-${item}-${pak##*/}"
			links+=("workshop-${item}-${pak##*/}")
		done < <(find "${dst}" -maxdepth 1 -type f -name '*.pak' -print0)
	elif [ "${shortname}" == "l4d2" ]; then
		# Legacy Workshop items download as <hash>_legacy.bin, which is the addon's .vpk.
		pak="$(find "${dst}" -maxdepth 1 -type f \( -name '*.vpk' -o -name '*_legacy.bin' \) -print -quit)"
		if [ -n "${pak}" ]; then
			mkdir -p "${workshoplinkdir}"
			ln -srfn "${pak}" "${workshoplinkdir}/${item}.vpk"
			links+=("${item}.vpk")
		fi
	elif [ "${shortname}" == "sol" ]; then
		# Soldat items mirror the server's maps, textures and scenery-gfx directories. The server only finds lowercase .pms maps.
		while IFS= read -r -d '' file; do
			rel="${file#"${dst}/"}"
			if [[ "${rel,,}" == maps/*.pms ]]; then
				rel="${rel%.*}.pms"
			fi
			if [ -e "${workshoplinkdir}/${rel}" ] || [ -L "${workshoplinkdir}/${rel}" ]; then
				fn_script_log_warn "Not linking ${rel} from ${workshoptitle[${item}]} (${item}): file already exists"
				continue
			fi
			mkdir -p "${workshoplinkdir}/${rel%/*}"
			ln -sr "${file}" "${workshoplinkdir}/${rel}"
			links+=("${rel}")
		done < <(find "${dst}" -mindepth 2 -type f -print0)
	fi
	local modname=""
	if [ "${shortname}" == "col" ] && [ -f "${dst}/modInfo.json" ]; then
		modname="$(jq -r 'if type == "array" then .[0].name else .name end // empty' "${dst}/modInfo.json" 2> /dev/null)"
	fi
	{
		echo "id=${item}"
		echo "modname=${modname}"
		echo "title=${workshoptitle[${item}]}"
		echo "timeupdated=${workshoptimeupdated[${item}]}"
		echo "keys=${keys[*]}"
		if [ "${#links[@]}" -gt 0 ]; then
			printf 'link=%s\n' "${links[@]}"
		fi
	} > "${dst}/.lgsm-workshop"
	fn_print_ok_nl "Installing ${workshoptitle[${item}]} (${item})"
	fn_script_log_pass "Installing ${workshoptitle[${item}]} (${item})"
}

# Removes an installed mod that is no longer in workshopmods.
fn_workshop_remove() {
	local item="$1"
	local title moddir
	title="$(fn_workshop_state "${item}" title)"
	moddir="$(fn_workshop_moddir "${item}")"
	workshopremovednames+=("$(fn_workshop_state "${item}" modname)")
	fn_print_dots "Removing ${title} (${item})"
	fn_workshop_remove_keys "${item}"
	fn_workshop_remove_links "${item}"
	if [ -n "${moddir}" ]; then
		rm -rf "${moddir:?}"
	fi
	fn_print_ok_nl "Removing ${title} (${item})"
	fn_script_log_pass "Removing ${title} (${item})"
}

# Barotrauma only loads mods listed in config_player.xml. Replaces LinuxGSM's entries with the installed mods, in order.
fn_workshop_bt_packages() {
	local config="${serverfiles}/config_player.xml"
	local item entries=""
	if [ ! -f "${config}" ]; then
		fn_print_warn_nl "${config} not found. Start the server once, then run ./${selfname} workshop-update to enable Workshop mods"
		fn_script_log_warn "${config} not found, Workshop mods not enabled"
		return
	fi
	sed -z -i 's#<regularpackages />#<regularpackages>\n    </regularpackages>#' "${config}"
	for item in "${workshopremovals[@]}" "${workshopitems[@]}"; do
		sed -z -i -E "s#[[:space:]]*<package[[:space:]]+path=\"LocalMods/${item}/filelist\\.xml\"[[:space:]]*/>##g" "${config}"
	done
	for item in "${workshopitems[@]}"; do
		if [ -f "${workshopdir}/${item}/filelist.xml" ]; then
			entries+="\\n      <package\\n        path=\"LocalMods/${item}/filelist.xml\" />"
		fi
	done
	sed -z -i -E "s#([[:space:]]*)</regularpackages>#${entries}\\1</regularpackages>#" "${config}"
	sed -z -i -E 's#<regularpackages>[[:space:]]*</regularpackages>#<regularpackages />#' "${config}"
}

# Colony Survival only loads mods enabled in each world's worldconfig.json. Replaces LinuxGSM's entries with the installed mods, in order.
fn_workshop_col_worlds() {
	local item name worldconfig managedjson enabledjson
	local managed=("${workshopremovednames[@]}")
	local enabled=()
	for item in "${workshopitems[@]}"; do
		name="$(fn_workshop_state "${item}" modname)"
		if [ -n "${name}" ]; then
			managed+=("${name}")
			enabled+=("${name}")
		fi
	done
	managedjson="$(jq -cn '$ARGS.positional' --args "${managed[@]}")"
	enabledjson="$(jq -cn '$ARGS.positional' --args "${enabled[@]}")"
	for worldconfig in "${serverfiles}"/gamedata/savegames/*/worldconfig.json; do
		if [ ! -f "${worldconfig}" ]; then
			fn_print_warn_nl "No Colony Survival world found. Start the server once, then run ./${selfname} workshop-update to enable Workshop mods"
			fn_script_log_warn "No Colony Survival world found, Workshop mods not enabled"
			return
		fi
		if jq -c --argjson managed "${managedjson}" --argjson enabled "${enabledjson}" '
			(.ModConfigEntries // []) as $old
			| ($old | map({key: .ModName, value: .}) | from_entries) as $existing
			| .ModConfigEntries = [$old[] | select(.ModName as $n | any($managed[]; . == $n) | not)]
				+ [$enabled[] | . as $n | ($existing[$n] // {ModName: $n, ModVersionLastKnown: "---"}) | .Enabled = true]
		' "${worldconfig}" > "${worldconfig}.tmp" 2> /dev/null; then
			mv "${worldconfig}.tmp" "${worldconfig}"
		else
			rm -f "${worldconfig}.tmp"
			fn_print_warn_nl "Unable to update ${worldconfig}"
			fn_script_log_warn "Unable to update ${worldconfig}"
		fi
	done
}

# Installs downloaded items and removes unused ones. Downloads happen first, so the server only stops for this step.
fn_workshop_apply() {
	local item
	workshopremovednames=()
	for item in "${workshopinstalls[@]}"; do
		fn_workshop_install "${item}"
	done
	for item in "${workshopremovals[@]}"; do
		fn_workshop_remove "${item}"
	done
	if [ "${shortname}" == "bt" ]; then
		fn_workshop_bt_packages
	elif [ "${shortname}" == "col" ]; then
		fn_workshop_col_worlds
	fi
	rm -rf "${workshopdldir:?}"
}

# Saves the resolved mod order so start can build the mod list without querying Steam.
fn_workshop_save_list() {
	if [ "${#workshopitems[@]}" -eq 0 ]; then
		rm -f "${workshopmodlist}"
		return
	fi
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
			fn_workshop_save_list
		fi
		return
	fi

	fn_print "\n"
	fn_print_nl "${bold}${underline}Update${default} available"
	for item in "${workshopupdates[@]}"; do
		if [ -n "$(fn_workshop_moddir "${item}")" ]; then
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

# Adds installed Workshop mods to the start parameters, in workshopmods order: -mod= for Arma 3 and DayZ, loadmod for Hurtworld.
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
		if [ -d "${workshopdir}/${workshopprefix}${item}" ] && [ "${shortname}" == "hw" ]; then
			workshoploadmods+=";loadmod ${item}"
		elif [ -d "${workshopdir}/${workshopprefix}${item}" ]; then
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

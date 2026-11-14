#!/bin/bash
# Checks lgsm/data/servers.json against serverlist.csv, the details port tables and the default configs.
# shellcheck disable=SC2329 # Stubs replace module functions called by fn_info_messages_select_engine.

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1

serversjson="lgsm/data/servers.json"
serverlist="lgsm/data/serverlist.csv"
configdir="lgsm/config-default/config-lgsm"
exitcode=0

fn_error() {
	echo "ERROR: ${1}"
	exitcode=1
}

if ! jq empty "${serversjson}"; then
	echo "ERROR: ${serversjson} is not valid JSON"
	exit 1
fi

echo "Checking that servers.json and serverlist.csv list the same servers"
csvservers="$(tail -n +2 "${serverlist}" | cut -d ',' -f2 | sort)"
jsonservers="$(jq -r '.servers | keys[]' "${serversjson}")"
while read -r gameservername; do
	fn_error "${gameservername} is in serverlist.csv but not in servers.json"
done < <(comm -23 <(echo "${csvservers}") <(echo "${jsonservers}") | sed '/^$/d')
while read -r gameservername; do
	fn_error "${gameservername} is in servers.json but not in serverlist.csv"
done < <(comm -13 <(echo "${csvservers}") <(echo "${jsonservers}") | sed '/^$/d')

if [ "$(jq -r '.servers | keys_unsorted[]' "${serversjson}")" != "${jsonservers}" ]; then
	fn_error "servers in servers.json are not in alphabetical order"
fi

echo "Checking ports against info_messages.sh and _default.cfg"
while IFS=',' read -r shortname gameservername _; do
	[ -n "$(jq -r --arg g "${gameservername}" '.servers[$g] // empty' "${serversjson}")" ] || continue
	defaultcfg="${configdir}/${gameservername}/_default.cfg"

	expected="$(
		(
			# shellcheck source=/dev/null
			source "${defaultcfg}"
			ase="Enabled"
			# shellcheck source=/dev/null
			source lgsm/modules/info_messages.sh > /dev/null 2>&1
			fn_port() {
				[ "${1}" == "header" ] || printf 'PORTROW\t%s\t%s\t%s\n' "${1}" "${2}" "${3}"
			}
			column() {
				cat
			}
			fn_messages_separator() {
				:
			}
			fn_print_error_nl() {
				:
			}
			fn_info_messages_select_engine
		) 2> /dev/null | sed -n 's/^PORTROW\t//p'
	)"
	actual="$(jq -r --arg g "${gameservername}" '.servers[$g].ports[] | .protocols[] as $p | [.label, .variable, $p] | @tsv' "${serversjson}")"
	if [ "$(sort <<< "${expected}")" != "$(sort <<< "${actual}")" ]; then
		fn_error "${gameservername} ports differ from info_messages.sh"
		diff <(sort <<< "${expected}") <(sort <<< "${actual}") | sed -n 's/^</  info_messages.sh:/p; s/^>/  servers.json:    /p'
	fi

	while IFS=$'\t' read -r variable default; do
		cfgvalue="$(sed -n "s/^${variable}=\"\([0-9]*\)\"$/\1/p" "${defaultcfg}" | head -n 1)"
		if [ -n "${cfgvalue}" ] && [ "${cfgvalue}" != "${default}" ]; then
			fn_error "${gameservername} ${variable} is ${cfgvalue} in _default.cfg but ${default:-null} in servers.json"
		fi
	done < <(jq -r --arg g "${gameservername}" '.servers[$g].ports | unique_by(.variable)[] | [.variable, (.default // "" | tostring)] | @tsv' "${serversjson}")
done < <(tail -n +2 "${serverlist}")

echo "Ports with no default and no note:"
jq -r '.servers | to_entries[] | .key as $g | .value.ports[] | select(.default == null and .note == null) | "  \($g) \(.variable)"' "${serversjson}" | sort -u

exit "${exitcode}"

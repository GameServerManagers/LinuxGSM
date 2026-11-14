#!/bin/bash
# Runs the details check for each shortname given, in one shared LinuxGSM directory.
# Modules, default configs and data come from the checkout, so the code under test is used and nothing is downloaded per server.
# Usage: details-check-run.sh <shortname>...

src="${GITHUB_WORKSPACE:-${PWD}}"
workdir="${DETAILS_CHECK_DIR:-${HOME}/details-check}"
summary="${GITHUB_STEP_SUMMARY:-/dev/null}"
export LGSM_GITHUBBRANCH="${LGSM_REF:?LGSM_REF must be set}"

testservername="LinuxGSM Test = Server: 1, ok"
testpassword="abc123=="

declare -A roundtripallow=(
	["cmwserver:adminpassword"]="AdminPassword in the config is not parsed"
	["codwawserver:adminpassword"]="parser reads rcon_password, stock config sets rconpassword"
	["ecoserver:ports"]="jq prints null when RconServerPort is missing from the stock config"
	["ohdserver:servername"]="ServerName in Game.ini is not parsed"
	["wetserver:adminpassword"]="parser reads zmq_rcon_password, stock config sets rconpassword"
)

rm -rf "${workdir}"
mkdir -p "${workdir}/lgsm" "${workdir}/serverfiles"
cp "${src}/linuxgsm.sh" "${workdir}/"
cp -r "${src}/lgsm/modules" "${src}/lgsm/config-default" "${src}/lgsm/data" "${workdir}/lgsm/"
cd "${workdir}" || exit 1
date '+%s' > .dev-debug

result() {
	if [ "${1}" -eq 0 ]; then echo "✅ pass"; else echo "❌ fail"; fi
}

fn_parse_details() {
	./"${gameserver}" parse-game-details > "${1}" 2>&1
	local exitcode=$?
	cat "${1}"
	sed -n '/Available Gameserver Details/,/Missing or unsupported Gameserver Details/p' "${1}" | sed 's/\x1b\[[0-9;]*m//g' > "${1}.values"
	return "${exitcode}"
}

fn_detail_value() {
	sed -n "s/^${2}: //p" "${1}.values" | head -n 1
}

fn_allowed() {
	if [ -n "${roundtripallow[${gameserver}:${1}]}" ]; then
		[[ " ${roundtripskipped[*]} " == *" ${1} "* ]] || roundtripskipped+=("${1}")
		return 0
	fi
	return 1
}

fn_check_values() {
	local label="${1}" file="${2}" line key value
	if grep -q $'\r' "${file}.values" && ! fn_allowed carriagereturn; then
		roundtriperrors+=("${label}: carriage return in $(grep $'\r' "${file}.values" | cut -d: -f1 | paste -sd, -)")
	fi
	fn_allowed ports && return
	while IFS= read -r line; do
		key="${line%%: *}"
		value="${line#*: }"
		if [[ ! "${value}" =~ ^[0-9]+$ ]]; then
			roundtriperrors+=("${label}: ${key} is not numeric (${value%$'\r'})")
		fi
	done < <(grep -E '^[^:]*Port[^:]*: ' "${file}.values")
}

fn_roundtrip_check() {
	local check="${1}" expected="${2}"
	shift 2
	local key value
	fn_allowed "${check}" && return
	for key in "$@"; do
		value=$(fn_detail_value parse-test "${key}")
		[ "${value}" == "${expected}" ] && return
	done
	value=$(fn_detail_value parse-test "${1}")
	roundtriperrors+=("${check}: expected '${expected}', got '${value%$'\r'}'")
}

failed=()
{
	echo "| Server | Config | Details | Parse game details | Query raw | Round trip |"
	echo "|--------|--------|---------|--------------------|-----------|------------|"
} >> "${summary}"

for shortname in "$@"; do
	gameserver="${shortname}server"
	roundtriperrors=()
	roundtripskipped=()
	rm -f config config-stock parse-stock parse-stock.values parse-test parse-test.values
	echo "::group::${gameserver}"
	./linuxgsm.sh "${gameserver}"

	servercfg=$(sed -n "/^\<servercfgdefault\>/ { s/.*= *\"\?\([^\"']*\)\"\?/\1/p;q }" "lgsm/config-default/config-lgsm/${gameserver}/_default.cfg")
	if [ -n "${servercfg}" ]; then
		cfgpath="${servercfg}"
		[[ "${cfgpath}" == \$\{*\}/* ]] && cfgpath="${cfgpath#*\}/}"
		curl -fsS -o config-stock "https://raw.githubusercontent.com/GameServerManagers/Game-Server-Configs/main/${shortname}/${cfgpath}"
		config=$?
		[ "${config}" -eq 0 ] && cat config-stock && cp config-stock config
		configresult=$(result "${config}")
	else
		echo "This game server has no config file."
		config=0
		configresult="➖ none"
	fi
	grep "startparameters" "lgsm/config-default/config-lgsm/${gameserver}/_default.cfg"

	./"${gameserver}" details
	details=$?
	fn_parse_details parse-stock
	parse=$?
	fn_check_values stock parse-stock

	if [ -f config-stock ]; then
		sed -e "s|SERVERNAME|${testservername}|g" -e "s|ADMINPASSWORD|${testpassword}|g" config-stock > config
		echo "Round trip: SERVERNAME=${testservername} ADMINPASSWORD=${testpassword}"
		fn_parse_details parse-test
		fn_check_values test parse-test
		if grep -q SERVERNAME config-stock; then
			fn_roundtrip_check servername "${testservername}" "Server Name"
		fi
		if grep -q ADMINPASSWORD config-stock; then
			fn_roundtrip_check adminpassword "${testpassword}" "Admin Password" "RCON Password"
		fi
		cp config-stock config
	fi

	./"${gameserver}" query-raw
	query=$?
	echo "::endgroup::"

	if [ "${#roundtriperrors[@]}" -gt 0 ]; then
		roundtrip=1
		roundtripresult="❌ fail: $(printf '%s; ' "${roundtriperrors[@]}" | sed 's/; $//; s/|/\\|/g')"
		echo "::error title=${gameserver} round trip::$(printf '%s; ' "${roundtriperrors[@]}" | sed 's/; $//')"
	else
		roundtrip=0
		if [ -f config-stock ]; then
			roundtripresult="✅ pass"
		else
			roundtripresult="➖ none"
		fi
		[ "${#roundtripskipped[@]}" -gt 0 ] && roundtripresult+=" (allowed: ${roundtripskipped[*]})"
	fi

	if [ "${config}" -ne 0 ] || [ "${details}" -ne 0 ] || [ "${parse}" -ne 0 ] || [ "${query}" -ne 0 ] || [ "${roundtrip}" -ne 0 ]; then
		failed+=("${gameserver}")
		echo "::error title=${gameserver}::config=${config} details=${details} parse-game-details=${parse} query-raw=${query} round-trip=${roundtrip}"
	fi
	echo "| ${gameserver} | ${configresult} | $(result "${details}") | $(result "${parse}") | $(result "${query}") | ${roundtripresult} |" >> "${summary}"
done

if [ "${#failed[@]}" -gt 0 ]; then
	echo -e "\n**Failed:** ${failed[*]}" >> "${summary}"
	exit 1
fi

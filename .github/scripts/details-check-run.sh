#!/bin/bash
# Runs the details check for each shortname given, in one shared LinuxGSM directory.
# Modules, default configs and data come from the checkout, so the code under test is used and nothing is downloaded per server.
# Usage: details-check-run.sh <shortname>...

src="${GITHUB_WORKSPACE:-${PWD}}"
workdir="${DETAILS_CHECK_DIR:-${HOME}/details-check}"
summary="${GITHUB_STEP_SUMMARY:-/dev/null}"
export LGSM_GITHUBBRANCH="${LGSM_REF:?LGSM_REF must be set}"

rm -rf "${workdir}"
mkdir -p "${workdir}/lgsm" "${workdir}/serverfiles"
cp "${src}/linuxgsm.sh" "${workdir}/"
cp -r "${src}/lgsm/modules" "${src}/lgsm/config-default" "${src}/lgsm/data" "${workdir}/lgsm/"
cd "${workdir}" || exit 1

result() {
	if [ "${1}" -eq 0 ]; then echo "✅ pass"; else echo "❌ fail"; fi
}

failed=()
{
	echo "| Server | Config | Details | Parse game details | Query raw |"
	echo "|--------|--------|---------|--------------------|-----------|"
} >> "${summary}"

for shortname in "$@"; do
	gameserver="${shortname}server"
	echo "::group::${gameserver}"
	./linuxgsm.sh "${gameserver}"
	./"${gameserver}" developer

	servercfg=$(sed -n "/^\<servercfgdefault\>/ { s/.*= *\"\?\([^\"']*\)\"\?/\1/p;q }" "lgsm/config-lgsm/${gameserver}/_default.cfg")
	if [ -n "${servercfg}" ]; then
		cfgpath="${servercfg}"
		[[ "${cfgpath}" == \$\{*\}/* ]] && cfgpath="${cfgpath#*\}/}"
		curl -fsS -o "config-${shortname}" "https://raw.githubusercontent.com/GameServerManagers/Game-Server-Configs/main/${shortname}/${cfgpath}"
		config=$?
		[ "${config}" -eq 0 ] && cat "config-${shortname}"
		configresult=$(result "${config}")
	else
		echo "This game server has no config file."
		config=0
		configresult="➖ none"
	fi
	grep "startparameters" "lgsm/config-default/config-lgsm/${gameserver}/_default.cfg"

	./"${gameserver}" details
	details=$?
	./"${gameserver}" parse-game-details
	parse=$?
	./"${gameserver}" query-raw
	query=$?
	echo "::endgroup::"

	if [ "${config}" -ne 0 ] || [ "${details}" -ne 0 ] || [ "${parse}" -ne 0 ] || [ "${query}" -ne 0 ]; then
		failed+=("${gameserver}")
		echo "::error title=${gameserver}::config=${config} details=${details} parse-game-details=${parse} query-raw=${query}"
	fi
	echo "| ${gameserver} | ${configresult} | $(result "${details}") | $(result "${parse}") | $(result "${query}") |" >> "${summary}"
done

if [ "${#failed[@]}" -gt 0 ]; then
	echo -e "\n**Failed:** ${failed[*]}" >> "${summary}"
	exit 1
fi

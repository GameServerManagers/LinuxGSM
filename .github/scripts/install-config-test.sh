#!/bin/bash
# Regression checks for default config source directories; no game downloads.
set -e

rootdir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
module="${rootdir}/lgsm/modules/install_config.sh"
testdir="$(mktemp -d)"
trap 'rm -rf "${testdir}"' EXIT

# Load only the helpers, without running the game-specific install dispatch.
for helper in fn_check_cfgdir fn_default_config_local fn_default_config_remote fn_set_config_vars; do
	# shellcheck disable=SC1090
	source <(sed -n "/^${helper}() {/,/^}/p" "${module}")
done

fn_messages_separator() { :; }
fn_sleep_time() { :; }
fn_sleep_time_1() { :; }
fn_script_log_info() { :; }
fn_script_log_pass() { :; }
fn_script_log_fail() { :; }
fn_print_ok_eol() { :; }
fn_print_ok_eol_nl() { :; }
fn_print_fail_eol() { :; }
fn_print_fail_eol_nl() { :; }
fn_print_skip_eol_nl() { :; }
fn_fetch_file() {
	mkdir -p "${5}"
	printf '%s\n' "template ${6}" > "${5}/${6}"
}

assert_content() {
	if [ "$(cat "${1}")" != "${2}" ]; then
		echo "FAIL: unexpected contents in ${1}" >&2
		exit 1
	fi
}

servercfgdir="${testdir}/active configs"
servercfgdirdefault="${testdir}/bundled templates"
servercfgdefault="server.cfg"
servercfgfullpath="${servercfgdir}/nested/instance.cfg"
mkdir -p "${servercfgdirdefault}"
printf '%s\n' template > "${servercfgdirdefault}/${servercfgdefault}"
fn_default_config_local > /dev/null
assert_content "${servercfgfullpath}" template
printf '%s\n' customised > "${servercfgfullpath}"
fn_default_config_local > /dev/null
assert_content "${servercfgfullpath}" customised

unset servercfgdirdefault
printf '%s\n' legacy > "${servercfgdir}/${servercfgdefault}"
servercfgfullpath="${servercfgdir}/legacy.cfg"
fn_default_config_local > /dev/null
assert_content "${servercfgfullpath}" legacy
servercfgdirdefault=""
servercfgfullpath="${servercfgdir}/empty.cfg"
fn_default_config_local > /dev/null
assert_content "${servercfgfullpath}" legacy

# Preserve relative subdirectories in template filenames (e.g. pc2).
servercfgdefault="config_sample/server.cfg"
mkdir -p "${servercfgdir}/config_sample"
printf '%s\n' nested > "${servercfgdir}/${servercfgdefault}"
servercfgfullpath="${servercfgdir}/sample.cfg"
fn_default_config_local > /dev/null
assert_content "${servercfgfullpath}" nested

servercfgdefault="missing.cfg"
servercfgfullpath="${servercfgdir}/missing-instance.cfg"
set +e
fn_default_config_local > /dev/null 2>&1
set -e
[ "${exitcode}" -ne 0 ]
[ ! -e "${servercfgfullpath}" ]

lgsmdir="${testdir}/lgsm"
shortname="arma3"
servercfgdir="${testdir}/remote configs"
servercfgdirdefault="${testdir}/download cache"
servercfgdefault="server.cfg"
servercfgfullpath="${servercfgdir}/instance.cfg"
networkcfgdefault="network.cfg"
networkcfgfullpath="${servercfgdir}/instance-network.cfg"
array_configs=(server.cfg network.cfg extra.cfg)
fn_default_config_remote > /dev/null
assert_content "${servercfgfullpath}" 'template server.cfg'
assert_content "${networkcfgfullpath}" 'template network.cfg'
assert_content "${servercfgdir}/extra.cfg" 'template extra.cfg'
assert_content "${servercfgdirdefault}/server.cfg" 'template server.cfg'
printf '%s\n' customised > "${servercfgfullpath}"
fn_default_config_remote > /dev/null
assert_content "${servercfgfullpath}" customised

# Template lookup must honour the same custom cache during substitutions.
config="server.cfg"
printf '%s\n' 'SERVERNAME="SERVERNAME"' > "${servercfgdirdefault}/${config}"
cp "${servercfgdirdefault}/${config}" "${servercfgfullpath}"
fn_set_config_vars > /dev/null
assert_content "${servercfgfullpath}" 'SERVERNAME="LinuxGSM"'

shortname="dst"
clustercfgdefault="cluster.ini"
clustercfgfullpath="${testdir}/cluster/instance.ini"
mkdir -p "$(dirname "${clustercfgfullpath}")"
array_configs=(cluster.ini)
fn_default_config_remote > /dev/null
assert_content "${clustercfgfullpath}" 'template cluster.ini'

shortname="test"
array_configs=(server.cfg)
unset servercfgdirdefault
servercfgfullpath="${servercfgdir}/remote-legacy.cfg"
fn_default_config_remote > /dev/null
assert_content "${servercfgfullpath}" 'template server.cfg'
assert_content "${lgsmdir}/config-default/config-game/server.cfg" 'template server.cfg'
servercfgdirdefault=""
servercfgfullpath="${servercfgdir}/remote-empty.cfg"
fn_default_config_remote > /dev/null
assert_content "${servercfgfullpath}" 'template server.cfg'

echo 'PASS: local and remote config source directories, fallbacks, substitutions, and existing configs'

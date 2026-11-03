#!/bin/bash
# Offline regression tests for the QuakeWorld release updater.
# Run from any directory: bash tests/test_update_qw.sh

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fixture=$(mktemp -d)
trap 'rm -rf "${fixture}"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}
assert() { "$@" || fail "$*"; }
expect_failure() {
  if ("$@") > "${fixture}/failure.log" 2>&1; then
    fail "Expected failure: $*"
  fi
}

# Quiet the UI, but retain the real hash and extraction implementations.
for name in fn_print_dots fn_print_ok fn_print_ok_nl fn_print_nl fn_print fn_print_error fn_print_fail_nl fn_print_fail_eol_nl fn_print_ok_eol_nl fn_sleep_time fn_script_log_info fn_script_log_pass fn_script_log_error fn_clear_tmp; do
  eval "${name}() { :; }"
done
fn_script_log_fail() { exitcode=1; }
core_exit.sh() { exit "${exitcode:-1}"; }
alert.sh() { printf '%s\n' "${alert}" >> "${fixture}/alerts"; }
# shellcheck source=/dev/null
source "${repo}/lgsm/modules/core_dl.sh"
# Load module functions without running its install/update entry point.
# shellcheck source=/dev/null
source <(sed '/^# The location where the builds are checked and downloaded\./,$d' "${repo}/lgsm/modules/update_qw.sh")

curl() {
  case "${*: -1}" in
    */releases/latest) cat "${fixture}/release.json" ;;
    */SHA256SUMS) cat "${fixture}/SHA256SUMS" ;;
    *) return 22 ;;
  esac
}
fn_fetch_file() {
  local_filedir="${5}"
  local_filename="${6}"
  hash="${10}"
  cp "${fixture}/bundle.tar.xz" "${local_filedir}/${local_filename}" || fail 'Fixture copy failed'
  fn_dl_hash
}
fn_update_apply() {
  echo apply >> "${fixture}/applied"
  "$@"
}

rootdir="${fixture}"
tmpdir="${fixture}/tmp"
serverfiles="${fixture}/serverfiles"
lockdir="${fixture}/locks"
lgsmlog="${fixture}/script.log"
servercfgfullpath="${serverfiles}/ktx/custom.settings"
remotelocation="github.com"
mkdir -p "${tmpdir}" "${serverfiles}" "${lockdir}" "${fixture}/bundle/ktx" "${fixture}/bundle/qtv" "${fixture}/bundle/qwfwd"
printf 'new binary\n' > "${fixture}/bundle/mvdsv"
chmod +x "${fixture}/bundle/mvdsv"
printf 'new KTX\n' > "${fixture}/bundle/ktx/qwprogs.so"
for config in ktx/server.cfg ktx/new.cfg ktx/mapcycle.txt ktx/custom.settings ktx/linked.cfg ktx/dangling.cfg qtv/qtv.cfg qwfwd/qwfwd.cfg start.sh; do
  printf 'default\n' > "${fixture}/bundle/${config}"
done
filename="nquake.server.linux.20261102.full.tar.xz"
cat > "${fixture}/release.json" << EOF
{"tag_name":"build-20261102","assets":[
{"name":"nquake.server.linux.latest.full.tar.xz","browser_download_url":"https://example.test/latest.tar.xz"},
{"name":"${filename}","browser_download_url":"https://example.test/${filename}"},
{"name":"SHA256SUMS","browser_download_url":"https://example.test/SHA256SUMS"}]}
EOF
cp "${fixture}/release.json" "${fixture}/valid-release.json"
make_bundle() {
  tar -cJf "${fixture}/bundle.tar.xz" -C "${fixture}/bundle" . || fail 'Fixture archive failed'
  printf '%s  %s\n' "$(sha256sum "${fixture}/bundle.tar.xz" | cut -d ' ' -f 1)" "${filename}" > "${fixture}/SHA256SUMS"
  printf '%064d  nquake.server.linux.latest.full.tar.xz\n' 0 >> "${fixture}/SHA256SUMS"
}
make_bundle

# Fresh install: select the dated asset, verify SHA-256 and install all defaults.
firstcommandname=INSTALL
fn_update_remotebuild
assert test "${remotebuildfilename}" = "${filename}"
fn_update_dl
assert test -x "${serverfiles}/mvdsv"
assert test -f "${serverfiles}/ktx/qwprogs.so"
assert grep -qx default "${serverfiles}/ktx/server.cfg"
assert grep -qx build-20261102 "${serverfiles}/build.txt"
echo 'PASS: fresh install and dated asset selection'

# Upgrade a legacy installation, preserving configs and symlinks but replacing binaries.
rm "${serverfiles}/build.txt" "${serverfiles}/ktx/new.cfg" "${serverfiles}/ktx/linked.cfg" "${serverfiles}/ktx/dangling.cfg"
printf 'link target\n' > "${fixture}/config-target"
ln -s "${fixture}/config-target" "${serverfiles}/ktx/linked.cfg"
ln -s "${fixture}/missing-target" "${serverfiles}/ktx/dangling.cfg"
for config in ktx/server.cfg ktx/mapcycle.txt ktx/custom.settings qtv/qtv.cfg qwfwd/qwfwd.cfg start.sh; do
  printf 'user content\n' > "${serverfiles}/${config}"
done
printf 'old binary\n' > "${serverfiles}/mvdsv"
printf 'keep demo\n' > "${serverfiles}/ktx/demo.mvd"
firstcommandname=UPDATE
commandname=UPDATE
fn_update_localbuild
assert test "${localbuild}" = 0
fn_update_compare
for config in ktx/server.cfg ktx/mapcycle.txt ktx/custom.settings qtv/qtv.cfg qwfwd/qwfwd.cfg start.sh; do
  assert grep -qx 'user content' "${serverfiles}/${config}"
done
assert test -L "${serverfiles}/ktx/linked.cfg"
assert test -L "${serverfiles}/ktx/dangling.cfg"
assert grep -qx 'link target' "${fixture}/config-target"
assert grep -qx 'keep demo' "${serverfiles}/ktx/demo.mvd"
assert grep -qx 'new binary' "${serverfiles}/mvdsv"
assert grep -qx default "${serverfiles}/ktx/new.cfg"
echo 'PASS: legacy upgrade preserves configs, scripts, symlinks and user data'

fn_update_localbuild
rm "${fixture}/applied" "${fixture}/alerts"
fn_update_compare
assert test ! -e "${fixture}/applied"
assert test ! -e "${fixture}/alerts"
commandname=CHECK-UPDATE
localbuild=0
fn_update_compare
assert test ! -e "${fixture}/applied"
assert grep -qx check-update "${fixture}/alerts"
echo 'PASS: unchanged release and check-update do not apply an update'

# Fail closed on invalid API responses, absent/ambiguous assets and checksum errors.
for response in '{}' '{"message":"API rate limit exceeded"}' 'not json' '{"tag_name":"latest","assets":[]}'; do
  printf '%s\n' "${response}" > "${fixture}/release.json"
  expect_failure fn_update_remotebuild
done
for filter in 'del(.assets[1])' '.assets += [.assets[1]]' 'del(.assets[2])' '.assets[1].browser_download_url = null'; do
  jq "${filter}" "${fixture}/valid-release.json" > "${fixture}/release.json"
  expect_failure fn_update_remotebuild
done
cp "${fixture}/valid-release.json" "${fixture}/release.json"
cp "${fixture}/SHA256SUMS" "${fixture}/valid-sums"
for sums in '' "invalid  ${filename}" "$(cat "${fixture}/valid-sums" "${fixture}/valid-sums")"; do
  printf '%s\n' "${sums}" > "${fixture}/SHA256SUMS"
  expect_failure fn_update_remotebuild
done
cp "${fixture}/valid-sums" "${fixture}/SHA256SUMS"
fn_update_remotebuild
printf 'old-build\n' > "${serverfiles}/build.txt"
printf 'corrupt' >> "${fixture}/bundle.tar.xz"
expect_failure fn_update_dl
assert grep -qx old-build "${serverfiles}/build.txt"
assert grep -qx 'new binary' "${serverfiles}/mvdsv"
echo 'PASS: invalid metadata/checksums and corrupt downloads fail without recording a build'

# Valid checksum with a malformed layout must not modify the installation.
rm "${fixture}/bundle/ktx/qwprogs.so"
make_bundle
fn_update_remotebuild
expect_failure fn_update_dl
assert grep -qx old-build "${serverfiles}/build.txt"
assert test -f "${serverfiles}/ktx/qwprogs.so"
echo 'PASS: invalid archive layout leaves installed files untouched'

# A failed copy must not advance build.txt.
printf 'KTX\n' > "${fixture}/bundle/ktx/qwprogs.so"
make_bundle
fn_update_remotebuild
(
  # shellcheck disable=SC2329 # Called indirectly by fn_update_dl.
  fn_fetch_file() { :; }
  command cp "${fixture}/bundle.tar.xz" "${tmpdir}/${remotebuildfilename}"
  # shellcheck disable=SC2329 # Called indirectly by fn_update_dl.
  cp() { return 1; }
  expect_failure fn_update_dl
) || fail 'Copy failure test failed'
assert grep -qx old-build "${serverfiles}/build.txt"
echo 'PASS: copy failure does not advance build.txt'
# Network errors must fail before touching serverfiles.
(
  # shellcheck disable=SC2329 # Called indirectly by fn_update_remotebuild.
  curl() { return 22; }
  expect_failure fn_update_remotebuild
) || fail 'Network failure test failed'
assert grep -qx old-build "${serverfiles}/build.txt"
echo 'PASS: release network errors fail closed'

# Exercise the public command routing (other Quake games remain excluded).
for option in update check-update; do
  (
    shortname=qw
    engine=quake
    getopt="${option}"
    # shellcheck disable=SC2329 # Called by the sourced command router.
    command_update.sh() { exit 0; }
    # shellcheck disable=SC2329 # Called by the sourced command router.
    command_check_update.sh() { exit 0; }
    # shellcheck source=/dev/null
    source "${repo}/lgsm/modules/core_getopt.sh"
  ) || fail "QuakeWorld ${option} not exposed"
done
for module in command_update command_check_update; do
  (
    shortname=qw
    for name in fn_firstcommand_set check.sh core_logs.sh check_update_lock.sh check_last_update.sh; do
      eval "${name}() { :; }"
    done
    # shellcheck disable=SC2329 # Called by the sourced command router.
    update_qw.sh() { exit 0; }
    # shellcheck disable=SC2329 # Called by the sourced command router.
    update_steamcmd.sh() { fail 'QuakeWorld routed to SteamCMD'; }
    # shellcheck source=/dev/null
    source "${repo}/lgsm/modules/${module}.sh"
  ) || fail "${module} routing failed"
done
echo 'PASS: update and check-update are exposed and route to the QuakeWorld module'
echo 'All QuakeWorld updater tests passed.'

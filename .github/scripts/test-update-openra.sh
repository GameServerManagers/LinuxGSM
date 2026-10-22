#!/bin/bash
# shellcheck disable=SC2329 # Overrides are called by the sourced updater.
set -euo pipefail
worktree="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
testdir=$(mktemp -d)
trap 'rm -rf "${testdir}"' EXIT
sed '/^# The location where the builds are checked and downloaded/,$d' "${worktree}/lgsm/modules/update_openra.sh" > "${testdir}/functions.sh"
# shellcheck source=/dev/null
source "${testdir}/functions.sh"
fn_print_fail_nl() { printf '%s\n' "$*"; }
fn_print_ok() { :; }
fn_script_log_fail() { :; }
fn_script_log_pass() { :; }
core_exit.sh() { exit "${exitcode:-1}"; }
fn_fetch_file() { :; }
fn_clear_tmp() { :; }
serverfiles="${testdir}/serverfiles"
tmpdir="${testdir}/tmp"
mkdir -p "${serverfiles}/openra" "${serverfiles}/data" "${tmpdir}"
printf 'old-release\n' > "${serverfiles}/openra/build.txt"
printf 'existing-engine\n' > "${serverfiles}/openra/keep.txt"
printf 'instance-data\n' > "${serverfiles}/data/keep.txt"
remotebuildfilename="broken.AppImage"
remotebuild="release-20250330"
remotebuildurl="https://example.invalid/broken.AppImage"
printf '#!/bin/sh\nexit 1\n' > "${tmpdir}/${remotebuildfilename}"
chmod +x "${tmpdir}/${remotebuildfilename}"
if (fn_update_dl); then
	echo 'FAIL: broken extraction was accepted'
	exit 1
fi
test "$(cat "${serverfiles}/openra/build.txt")" = old-release
test "$(cat "${serverfiles}/openra/keep.txt")" = existing-engine
test "$(cat "${serverfiles}/data/keep.txt")" = instance-data
echo 'PASS: failed extraction leaves the installed engine, metadata and data intact'
remotelocation="GitHub test fixture"
curl() { printf '%s\n' '{"tag_name":"release-20250330","assets":[]}'; }
if (fn_update_remotebuild); then
	echo 'FAIL: missing release asset was accepted'
	exit 1
fi
echo 'PASS: missing release asset is rejected'
curl() { printf '%s\n' 'invalid-json'; }
if (fn_update_remotebuild); then
	echo 'FAIL: malformed API response was accepted'
	exit 1
fi
echo 'PASS: malformed API response is rejected'
curl() { return 22; }
if (fn_update_remotebuild); then
	echo 'FAIL: HTTP failure was accepted'
	exit 1
fi
echo 'PASS: HTTP failure is rejected'

curl() { printf '%s\n' '{"tag_name":"release-20250330","assets":[{"name":"OpenRA-Red-Alert-x86_64.AppImage","browser_download_url":"https://example.invalid/wrong.AppImage"}]}'; }
if (fn_update_remotebuild); then
	echo 'FAIL: unexpected release asset origin was accepted'
	exit 1
fi
echo 'PASS: unexpected release asset origin is rejected'
uname() { printf 'aarch64\n'; }
if (fn_update_remotebuild); then
	echo 'FAIL: unsupported architecture was accepted'
	exit 1
fi
unset -f uname
echo 'PASS: unsupported architecture is rejected before download'
fn_print_dots() { :; }
fn_print_error() { :; }
fn_script_log_error() { :; }
fn_update_localbuild
test "${localbuild}" = 0
echo 'PASS: incomplete installations cannot be reported as up to date'

cat > "${tmpdir}/${remotebuildfilename}" << 'APPIMAGE'
#!/bin/sh
mkdir -p squashfs-root/usr/lib/openra
printf '#!/bin/sh\n' > squashfs-root/usr/lib/openra/OpenRA.Server
chmod +x squashfs-root/usr/lib/openra/OpenRA.Server
APPIMAGE
if (fn_update_dl); then
	echo 'FAIL: an extracted package without its launcher was accepted'
	exit 1
fi
test "$(cat "${serverfiles}/openra/build.txt")" = old-release
echo 'PASS: a missing package launcher leaves the old install intact'
cat >> "${tmpdir}/${remotebuildfilename}" << 'APPIMAGE'
printf '#!/bin/sh\n' > squashfs-root/AppRun
chmod +x squashfs-root/AppRun
APPIMAGE
mv() {
	if [[ "${1}" == */squashfs-root ]]; then
		return 1
	fi
	command mv "$@"
}
if (fn_update_dl); then
	echo 'FAIL: failed package replacement was accepted'
	exit 1
fi
unset -f mv
test "$(cat "${serverfiles}/openra/build.txt")" = old-release
test "$(cat "${serverfiles}/openra/keep.txt")" = existing-engine
test "$(cat "${serverfiles}/data/keep.txt")" = instance-data
echo 'PASS: failed package replacement restores the previous engine and metadata'
fn_update_dl
test "$(cat "${serverfiles}/openra/build.txt")" = release-20250330
test -x "${serverfiles}/openra/AppRun"
test "$(cat "${serverfiles}/data/keep.txt")" = instance-data
fn_update_localbuild
test "${localbuild}" = release-20250330
echo 'PASS: successful package replacement records the build and preserves instance data'

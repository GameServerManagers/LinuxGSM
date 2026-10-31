#!/usr/bin/env python3
"""Exercise real download functions with deterministic HTTP responses; no network required."""

import os
import re
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def functions(path):
    """Load Bash definitions without executing a launcher or module."""
    return "\n".join(
        re.findall(r"(?ms)^[\w.]+\(\) \{\n.*?^\}", path.read_text(encoding="utf-8"))
    )


BOOTSTRAP = functions(ROOT / "linuxgsm.sh")
DOWNLOAD = functions(ROOT / "lgsm/modules/core_dl.sh")
UPDATE = (
    (ROOT / "lgsm/modules/command_update_linuxgsm.sh")
    .read_text()
    .split("# Check linuxsm.sh", 1)[0]
)

MOCKS = r"""
githubuser="GameServerManagers"
githubrepo="LinuxGSM"
githubbranch="${TEST_BRANCH:-feature/example}"
version="v26.2.0"
rootdir="$TEST_DIR"
local_filedir="$TEST_DIR"
modulesdir="$TEST_DIR"
lgsmlog="$TEST_DIR/log"
fn_firstcommand_set() { :; }
fn_print_dots() { :; }
fn_script_log_info() { :; }
fn_script_log_fail() { printf '%s\n' "$*" >> "$TEST_DIR/log"; }
fn_print_fail_nl() { printf '%s\n' "$*"; }
fn_print_ok_nl() { :; }
check.sh() { :; }
info_distro.sh() { :; }
info_game.sh() { :; }
curl() {
    printf '%s\n' "$*" >> "$TEST_DIR/calls"
    local output="" probe="" url="${!#}"
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --write-out) probe=1; shift ;;
            -o) output="$2"; shift ;;
        esac
        shift
    done
    if [ "$probe" ]; then
        printf '%s' "${HTTP_CODE:-200}"
        return "${PROBE_EXIT:-0}"
    fi
    if [[ "$url" == https://raw.githubusercontent.com/* ]] && [ "${PRIMARY_FAIL:-0}" == 1 ]; then
        return 22
    fi
    if [ "$output" ]; then
        printf '#!/bin/bash\n' > "$output"
    fi
}
"""


class BranchValidation(unittest.TestCase):
    """Run production Bash with controlled HTTP responses and isolated files."""

    def run_bash(self, code, *, core=False, legacy=False, **env):
        """Return process results, HTTP calls, log output and download existence."""
        with tempfile.TemporaryDirectory() as directory:
            source = BOOTSTRAP + ("\n" + DOWNLOAD if core else "")
            if legacy:
                source += "\nunset -f fn_check_github_branch\n"
            result = subprocess.run(
                ["bash", "-c", source + "\n" + MOCKS + "\n" + code],
                env={**os.environ, "TEST_DIR": directory, **env},
                check=False,
                capture_output=True,
                text=True,
                timeout=10,
            )
            calls = Path(directory, "calls")
            log = Path(directory, "log")
            return (
                result,
                (
                    calls.read_text(encoding="utf-8").splitlines()
                    if calls.exists()
                    else []
                ),
                log.read_text(encoding="utf-8") if log.exists() else "",
                Path(directory, "sample.sh").exists(),
            )

    def fetch(self, core=False):
        """Build a call to the real bootstrap or core download entry point."""
        name = "fn_fetch_file_github" if core else "fn_bootstrap_fetch_file_github"
        return f'{name} lgsm/modules sample.sh "$TEST_DIR" nochmodx norun noforcedl nohash\n'

    def test_missing_reference_stops_before_bootstrap_download(self):
        """Missing reference stops before bootstrap download."""
        result, calls, log, exists = self.run_bash(self.fetch(), HTTP_CODE="404")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn(
            'Branch "feature/example" not found on GameServerManagers/LinuxGSM',
            result.stdout,
        )
        self.assertIn('Branch "feature/example"', log)
        self.assertEqual(len(calls), 1)
        self.assertFalse(exists)

    def test_missing_reference_with_loaded_core_exits_nonzero(self):
        """Missing reference with loaded core exits nonzero."""
        code = "core_exit.sh() { echo unexpected-exit-module; exit 0; }\n" + self.fetch(
            True
        )
        result, calls, _, exists = self.run_bash(code, core=True, HTTP_CODE="404")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual(len(calls), 1)
        self.assertFalse(exists)

    def test_valid_reference_is_checked_once_across_bootstrap_and_update(self):
        """Valid reference is checked once across bootstrap and update."""
        result, calls, _, exists = self.run_bash(self.fetch() + UPDATE)
        self.assertEqual(result.returncode, 0, result.stderr)
        probes = [call for call in calls if "api.github.com" in call]
        self.assertEqual(len(probes), 1)
        self.assertIn("--connect-timeout 3 --max-time 10", probes[0])
        self.assertIn("--data-urlencode ref=feature/example", probes[0])
        self.assertTrue(exists)

    def test_non404_failures_keep_bitbucket_fallback(self):
        """Non404 failures keep bitbucket fallback."""
        for core in (False, True):
            for status, exit_code in (
                ("403", "0"),
                ("429", "0"),
                ("500", "0"),
                ("503", "0"),
                ("000", "28"),
                ("000", "6"),
            ):
                with self.subTest(core=core, status=status, exit_code=exit_code):
                    result, calls, _, exists = self.run_bash(
                        self.fetch(core),
                        core=core,
                        HTTP_CODE=status,
                        PROBE_EXIT=exit_code,
                        PRIMARY_FAIL="1",
                    )
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertTrue(any("bitbucket.org" in call for call in calls))
                    self.assertTrue(exists)
                    self.assertNotIn("not found", result.stdout)

    def test_cached_file_needs_no_network(self):
        """Cached file needs no network."""
        for core in (False, True):
            with self.subTest(core=core):
                result, calls, _, _ = self.run_bash(
                    'touch "$TEST_DIR/sample.sh"\n' + self.fetch(core),
                    core=core,
                    HTTP_CODE="404",
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(calls, [])

    def test_update_missing_branch_stops_before_repo_selection(self):
        """Update missing branch stops before repo selection."""
        result, calls, _, _ = self.run_bash(UPDATE, HTTP_CODE="404")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual(len(calls), 1)
        self.assertIn("api.github.com", calls[0])

    def test_update_non404_keeps_repo_fallback(self):
        """Update non404 keeps repo fallback."""
        for status in ("429", "500", "000"):
            with self.subTest(status=status):
                result, calls, _, _ = self.run_bash(
                    UPDATE,
                    HTTP_CODE=status,
                    PRIMARY_FAIL="1",
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertTrue(any("bitbucket.org" in call for call in calls))

    def test_upstream_master_still_downloads_version_tag(self):
        """Upstream master still downloads version tag."""
        result, calls, _, _ = self.run_bash(self.fetch(), TEST_BRANCH="master")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("/v26.2.0/lgsm/modules/sample.sh", calls[-1])

    def test_fork_master_is_not_version_pinned(self):
        """Fork master is not version pinned."""
        result, calls, _, _ = self.run_bash(
            'githubuser="Example"\n' + self.fetch(), TEST_BRANCH="master"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("/Example/LinuxGSM/master/lgsm/modules/sample.sh", calls[-1])

    def test_ref_change_gets_new_validation(self):
        """Ref change gets new validation."""
        result, calls, _, _ = self.run_bash(
            "fn_check_github_branch\ngithubbranch=other\nfn_check_github_branch"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(calls), 2)

    def test_tags_and_commit_refs_are_passed_unchanged(self):
        """Tags and commit refs are passed unchanged."""
        for ref in ("v26.2.0", "2a494011fb636642b9a5d1332a79e359586c54f8"):
            with self.subTest(ref=ref):
                result, calls, _, _ = self.run_bash(self.fetch(), TEST_BRANCH=ref)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("ref=" + ref, calls[0])
                self.assertIn("/" + ref + "/", calls[-1])

    def test_new_modules_support_older_launchers(self):
        """New modules support older launchers."""
        for code in (self.fetch(True), UPDATE):
            with self.subTest(code=code[:30]):
                result, calls, _, _ = self.run_bash(code, core=True, legacy=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertFalse(any("api.github.com" in call for call in calls))

    def test_forced_cached_download_validates_ref(self):
        """A forced download must validate even when the destination exists."""
        for core in (False, True):
            with self.subTest(core=core):
                code = 'touch "$TEST_DIR/sample.sh"\n' + self.fetch(core).replace(
                    "noforcedl", "forcedl"
                )
                result, calls, _, _ = self.run_bash(code, core=core, HTTP_CODE="404")
                self.assertEqual(result.returncode, 1, result.stderr)
                self.assertEqual(len(calls), 1)

    def test_unrelated_download_does_not_validate_linuxgsm_ref(self):
        """Other GitHub repositories should not depend on LinuxGSM validation."""
        code = (
            "fn_fetch_file https://raw.githubusercontent.com/Other/Repo/main/file "
            '"" GitHub "" "$TEST_DIR" sample.sh nochmodx norun noforce nohash'
        )
        result, calls, _, exists = self.run_bash(code, core=True, HTTP_CODE="404")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(exists)
        self.assertEqual(len(calls), 1)
        self.assertNotIn("api.github.com", calls[0])


if __name__ == "__main__":
    unittest.main(verbosity=2)

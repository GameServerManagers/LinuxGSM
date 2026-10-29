#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
# The monitor runs when sourced, so load only the helper under test.
# shellcheck source=/dev/null
source <(sed -n '/^fn_monitor_query_port_hint() {/,/^}/p' lgsm/modules/command_monitor.sh)

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fn_print_warn() { printf '%s\n' "$*" >> "$tmp/screen"; }
fn_print_warn_eol_nl() { :; }
fn_script_log_warn() { printf '%s\n' "$*" >> "$tmp/log"; }
queryport=27016

socket_state=absent
ss() {
	case "$socket_state" in
		absent) printf '%s\n' 'udp UNCONN 0 0 0.0.0.0:270160 0.0.0.0:*' ;;
		used) printf '%s\n' 'tcp LISTEN 0 128 0.0.0.0:27016 0.0.0.0:* users:(("srcds",pid=123,fd=5))' ;;
		no_process) printf '%s\n' 'udp UNCONN 0 0 0.0.0.0:27016 0.0.0.0:*' ;;
		unavailable) return 1 ;;
	esac
}
check_output() {
	grep -Fq "$1" "$tmp/log"
	grep -Fq "$1" "$tmp/screen"
	[ "$(wc -l < "$tmp/log")" -eq 1 ]
	[ "$(wc -l < "$tmp/screen")" -eq 1 ]
}
: > "$tmp/log"
: > "$tmp/screen"
fn_monitor_query_port_hint
check_output 'No local TCP/UDP listener on port 27016'

: > "$tmp/log"
: > "$tmp/screen"
socket_state=used
fn_monitor_query_port_hint
check_output 'Local TCP/UDP port 27016 is in use by srcds'

: > "$tmp/log"
: > "$tmp/screen"
socket_state=no_process
fn_monitor_query_port_hint
check_output 'Local TCP/UDP port 27016 is in use; check the query port and protocol'

: > "$tmp/log"
: > "$tmp/screen"
socket_state=unavailable
fn_monitor_query_port_hint
[ ! -s "$tmp/log" ]
[ ! -s "$tmp/screen" ]
printf '%s\n' 'monitor query port hints: 4 checks passed'

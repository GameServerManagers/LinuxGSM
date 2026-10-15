#!/usr/bin/env bash
# sync-game-labels.sh
# Reads lgsm/data/serverlist.csv and ensures a "game: <name>" label exists in
# the GitHub repo for every unique game name. Safe to run multiple times.
#
# Requires: gh CLI authenticated with issues:write scope.
# Usage:    .github/scripts/sync-game-labels.sh [OWNER/REPO]
#
# The OWNER/REPO argument is optional; if omitted gh uses the current repo.

set -euo pipefail

REPO="${1:-}"
SERVERLIST="lgsm/data/serverlist.csv"
LABEL_COLOR="5b21b6"
LABEL_PREFIX="game: "

normalize_label() {
	printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

if [[ ! -f "${SERVERLIST}" ]]; then
	echo "ERROR: ${SERVERLIST} not found. Run from the repository root."
	exit 1
fi

declare -A EXISTING_COLORS=()
declare -A EXISTING_DESCRIPTIONS=()
declare -A EXISTING_NAMES=()

# Fetch all existing game label metadata once (up to 1000) and cache locally.
echo "Fetching existing labels..."
while IFS=$'\t' read -r NAME COLOR DESCRIPTION; do
	[[ -n "${NAME}" ]] || continue
	EXISTING_COLORS["${NAME}"]="${COLOR}"
	EXISTING_DESCRIPTIONS["${NAME}"]="${DESCRIPTION}"
	EXISTING_NAMES["$(normalize_label "${NAME}")"]="${NAME}"
done < <(
	gh label list --limit 1000 --json name,color,description ${REPO:+--repo "$REPO"} \
		| jq -r '.[] | select(.name | startswith("game: ")) | [.name, .color, (.description // "")] | @tsv'
)

# Parse unique game names from the CSV (column 3, skip header).
mapfile -t GAMES < <(
	tail -n +2 "${SERVERLIST}" \
		| cut -d',' -f3 \
		| sort -u
)

CREATED=0
UPDATED=0
UNCHANGED=0

for GAME in "${GAMES[@]}"; do
	LABEL="${LABEL_PREFIX}${GAME}"
	DESCRIPTION="Issues related to ${GAME}"
	NORMALIZED_LABEL="$(normalize_label "${LABEL}")"

	if [[ -v EXISTING_NAMES["${NORMALIZED_LABEL}"] ]]; then
		CURRENT_LABEL="${EXISTING_NAMES["${NORMALIZED_LABEL}"]}"
		CURRENT_COLOR="${EXISTING_COLORS["${CURRENT_LABEL}"]}"
		CURRENT_DESCRIPTION="${EXISTING_DESCRIPTIONS["${CURRENT_LABEL}"]}"

		if [[ "${CURRENT_LABEL}" != "${LABEL}" || "${CURRENT_COLOR}" != "${LABEL_COLOR}" || "${CURRENT_DESCRIPTION}" != "${DESCRIPTION}" ]]; then
			echo "  update  ${LABEL}"
			gh label edit "${CURRENT_LABEL}" \
				--name "${LABEL}" \
				--color "${LABEL_COLOR}" \
				--description "${DESCRIPTION}" \
				${REPO:+--repo "$REPO"}
			((UPDATED++)) || true
		else
			echo "  ok      ${LABEL}"
			((UNCHANGED++)) || true
		fi
	else
		echo "  create  ${LABEL}"
		gh label create "${LABEL}" \
			--color "${LABEL_COLOR}" \
			--description "${DESCRIPTION}" \
			${REPO:+--repo "$REPO"}
		((CREATED++)) || true
	fi
done

echo ""
echo "Done. Created: ${CREATED}  Updated: ${UPDATED}  Unchanged: ${UNCHANGED}"

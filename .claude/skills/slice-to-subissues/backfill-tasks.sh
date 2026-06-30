#!/usr/bin/env bash
#
# backfill-tasks.sh — set the spec's `tasks:` list to the created task issue numbers.
#
#   Usage:   backfill-tasks.sh <spec-#> <n1,n2,...> [owner/repo]
#   Dry run: DRY_RUN=1 backfill-tasks.sh <spec-#> <n1,n2,...> [owner/repo]
#
# Deterministic core of slice-to-subissues' final step (requirement-6 linkage). Re-pulls the
# canonical spec body from the issue, edits ONLY the `tasks:` line inside its ```yaml block,
# and writes the body back. The design body is never touched — only the metadata line.
#
# Output (stdout): a one-line confirmation.
set -eo pipefail

spec=${1:?usage: backfill-tasks.sh <spec-#> <n1,n2,...> [owner/repo]}
nums=${2:?missing comma-separated task numbers}
repo=${3:-}
if [ -n "$repo" ]; then nwo=$repo; else nwo=$(gh repo view --json nameWithOwner -q .nameWithOwner); fi

cur=$(mktemp); new=$(mktemp)
gh issue view "$spec" --repo "$nwo" --json body -q .body > "$cur"

# Replace the first `tasks:` line's value; leave the rest of the body byte-for-byte.
awk -v list="[$nums]" '
  !done && /^tasks:/ { sub(/:.*/, ": " list "                  # backfilled by slice-to-subissues"); done=1 }
  { print }
' "$cur" > "$new"

if ! grep -q "^tasks: \[$nums\]" "$new"; then
  echo "error: could not find a 'tasks:' line in spec #$spec body to backfill" >&2
  rm -f "$cur" "$new"; exit 1
fi

if [ -n "$DRY_RUN" ]; then
  echo "DRY RUN — would set spec #$spec tasks: [$nums]" >&2
  rm -f "$cur" "$new"
  exit 0
fi

gh issue edit "$spec" --repo "$nwo" --body-file "$new" >/dev/null
rm -f "$cur" "$new"
echo "spec #$spec tasks: backfilled to [$nums]"

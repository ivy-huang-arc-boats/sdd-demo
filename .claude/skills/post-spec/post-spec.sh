#!/usr/bin/env bash
#
# post-spec.sh — publish a .scratch spec draft as the canonical [Spec] issue.
#
#   Usage:   post-spec.sh <draft.md> [owner/repo]
#   Dry run: DRY_RUN=1 post-spec.sh <draft.md> [owner/repo]   # validate + show body, create nothing
#
# This is the deterministic core of the post-spec skill: it validates the draft is
# actually fillable, converts the leading `---` frontmatter to a ```yaml fence (so it
# renders cleanly in a GitHub issue), creates the issue with `spec,needs-approval`, and
# assigns the approvers — falling back to an @-mention comment if they aren't collaborators.
#
# It never sets `approved` (that's the deferred Action). The local draft is left untouched.
#
# Output (stdout): the created issue URL. Diagnostics go to stderr.
set -eo pipefail

draft=${1:?usage: post-spec.sh <draft.md> [owner/repo]}
repo=${2:-}
[ -f "$draft" ] || { echo "error: draft not found: $draft" >&2; exit 1; }

if [ -n "$repo" ]; then nwo=$repo; else nwo=$(gh repo view --json nameWithOwner -q .nameWithOwner); fi

# --- read frontmatter values -------------------------------------------------
fm() { awk -F': *' -v k="$1" '$1==k{sub(/^[^:]*: */,""); print; exit}' "$draft"; }
title=$(fm title)
approvers_raw=$(fm approvers | sed 's/[[:space:]]*#.*$//')   # strip any trailing inline comment

# --- validate: refuse to post a draft that isn't fillable --------------------
errs=()
case "$title" in
  ""|"<short descriptive title>") errs+=("title is empty or still the placeholder");;
esac
case "$approvers_raw" in
  ""|"[]"|*"<github-handle>"*) errs+=("approvers is empty or still a placeholder");;
esac
if grep -q '<!--' "$draft"; then errs+=("template HTML comments remain — draft not fully filled"); fi
if ! grep -q '^## Acceptance Criteria' "$draft"; then errs+=("missing '## Acceptance Criteria' section (the e2e contract)"); fi
# Acceptance Criteria must hold at least one real checkbox, not just the template's Criterion 1/2 stubs
real_ac=$(awk '/^## Acceptance Criteria/{a=1;next} /^## /{a=0} a&&/^- \[ \]/{print}' "$draft" | grep -cvE 'Criterion [12]$' || true)
if [ "${real_ac:-0}" -eq 0 ]; then errs+=("Acceptance Criteria has no real criteria (only template stubs or empty)"); fi

if [ "${#errs[@]}" -gt 0 ]; then
  echo "Refusing to post — draft is not fillable:" >&2
  printf '  - %s\n' "${errs[@]}" >&2
  exit 1
fi

# --- normalize approvers to a comma-separated handle list --------------------
approvers=$(printf '%s' "$approvers_raw" | tr -d '[]' | tr ',' '\n' | sed 's/^ *//;s/ *$//' | grep . | paste -sd, -)

# --- fence the frontmatter for GitHub (only the first --- ... --- block) ------
body=$(mktemp)
awk 'NR==1 && $0=="---"{print "```yaml"; f=1; next}
     f && $0=="---"{print "```"; f=0; next} {print}' "$draft" > "$body"

title_full="[Spec] $title"

if [ -n "$DRY_RUN" ]; then
  echo "DRY RUN — would create on $nwo:" >&2
  echo "  title:     $title_full" >&2
  echo "  labels:    spec,needs-approval" >&2
  echo "  assignees: $approvers" >&2
  echo "  --- fenced body ---" >&2
  cat "$body" >&2
  rm -f "$body"
  exit 0
fi

# --- create the issue, with approver-assignment fallback ---------------------
if url=$(gh issue create --repo "$nwo" --title "$title_full" --body-file "$body" \
           --label "spec,needs-approval" --assignee "$approvers" 2>/dev/null); then
  :
else
  echo "note: could not assign approvers ($approvers) — creating without assignees, will @-mention" >&2
  url=$(gh issue create --repo "$nwo" --title "$title_full" --body-file "$body" --label "spec,needs-approval")
  num=${url##*/}
  mentions=$(printf '%s' "$approvers" | sed 's/\([^,][^,]*\)/@\1/g')
  gh issue comment --repo "$nwo" "$num" --body "Approvers (could not auto-assign): $mentions — please review." >/dev/null
fi
rm -f "$body"
echo "$url"

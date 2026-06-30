#!/usr/bin/env bash
#
# create-task.sh — publish one [Task] sub-issue of a spec.
#
#   Usage:   create-task.sh <parent-spec-#> <task-draft.md> [owner/repo]
#   Dry run: DRY_RUN=1 create-task.sh <parent-#> <task-draft.md> [owner/repo]
#
# Deterministic core of slice-to-subissues' per-task step: fence the task draft's `---`
# frontmatter to a ```yaml block, create the issue with the `task` label, and link it as a
# NATIVE GitHub sub-issue of the parent spec (REST sub_issues API). The agent owns the
# decomposition and fills `blocked-by` before calling this; this script just publishes + links.
#
# Output (stdout): the new task issue number (just the integer, for easy capture).
set -eo pipefail

parent=${1:?usage: create-task.sh <parent-spec-#> <task-draft.md> [owner/repo]}
draft=${2:?missing task draft}
repo=${3:-}
[ -f "$draft" ] || { echo "error: draft not found: $draft" >&2; exit 1; }

if [ -n "$repo" ]; then nwo=$repo; else nwo=$(gh repo view --json nameWithOwner -q .nameWithOwner); fi

title=$(awk -F': *' '$1=="title"{sub(/^[^:]*: */,""); print; exit}' "$draft")
case "$title" in
  ""|"<short descriptive title>") echo "error: task title empty or still placeholder" >&2; exit 1;;
esac

body=$(mktemp)
awk 'NR==1 && $0=="---"{print "```yaml"; f=1; next}
     f && $0=="---"{print "```"; f=0; next} {print}' "$draft" > "$body"

if [ -n "$DRY_RUN" ]; then
  echo "DRY RUN — would create '[Task] $title' (label task) on $nwo and link under #$parent" >&2
  echo "  --- fenced body ---" >&2
  cat "$body" >&2
  rm -f "$body"
  exit 0
fi

url=$(gh issue create --repo "$nwo" --title "[Task] $title" --body-file "$body" --label task)
rm -f "$body"
num=${url##*/}

# link as a native sub-issue of the parent spec (sub_issue_id must be the integer DB id, not the number)
child_id=$(gh api "repos/$nwo/issues/$num" --jq .id)
gh api --method POST "repos/$nwo/issues/$parent/sub_issues" -F sub_issue_id="$child_id" >/dev/null

echo "$num"

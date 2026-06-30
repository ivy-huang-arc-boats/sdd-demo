---
name: post-spec
description: Post a .scratch spec draft to GitHub as a [Spec] issue, apply the needs-approval label, and assign the approvers declared in the draft's frontmatter.
disable-model-invocation: true
argument-hint: <path-to-draft.md>
allowed-tools:
  - Read
  - Glob
  - Bash(bash skills/post-spec/post-spec.sh:*)
  - Bash(bash .claude/skills/post-spec/post-spec.sh:*)
---

# post-spec

Push a finished spec draft from `.scratch/` up to GitHub as the canonical `[Spec]` issue.
After this runs, **the issue is the source of truth** — the local draft is no longer authoritative.

The deterministic mechanics — validation, fencing the frontmatter, creating the issue with labels and
approver assignees, and the assignee fallback — live in **`post-spec.sh`** (in this skill's directory) so
they run the same way every time. This skill's job is to resolve the draft, run the script, and relay the
result. Don't re-implement the mechanics in prose or inline `gh` calls — call the script.

## Process

1. **Resolve the draft.** The argument is the path to a `.scratch/` markdown file. If omitted, use the most
   recent `.scratch/*.md` and confirm with the user before posting.

2. **Run the script.** From the repo root (use the bundled path `.claude/skills/post-spec/post-spec.sh` when
   the suite is installed in a project):

   ```sh
   bash skills/post-spec/post-spec.sh <draft-path> [owner/repo]
   ```

   It validates the draft is fillable (real `title`/`approvers`, no leftover placeholders or template
   comments, a non-stub Acceptance Criteria), converts the draft's `---` frontmatter to a ` ```yaml ` fence
   (so it renders cleanly — the local draft is left untouched), creates the issue with `spec,needs-approval`,
   and assigns the approvers, falling back to an `@`-mention comment if they aren't collaborators. On success
   it prints the issue URL. *(Tip: `DRY_RUN=1 bash …` validates and prints the fenced body without creating
   anything — useful to preview.)*

3. **If it refuses (exit 1), stop.** The script lists exactly what's not fillable. Relay that, help fix the
   **draft**, and re-run — don't try to force the post past validation.

4. **Report.** Print the new issue URL the script returned. Next step: reviewers run `review-spec`; the author
   does **not** set `approved` — that's the Action, triggered by `/approve` or 👍.

## Notes

- `post-spec` never sets `approved`. It only ever applies `needs-approval`.
- The `.scratch` draft stays gitignored and is not committed. Drift is avoided by always re-pulling the
  issue body before later edits (`address-comments`) or implementation.
- The script is the source of truth for the mechanics; if behavior needs to change, change `post-spec.sh`,
  not a prose paraphrase of it.

---
name: post-spec
description: Post a .scratch spec draft to GitHub as a [Spec] issue, apply the needs-approval label, and assign the approvers declared in the draft's frontmatter.
disable-model-invocation: true
argument-hint: <path-to-draft.md>
allowed-tools:
  - Read
  - Glob
  - Bash(gh issue create:*)
  - Bash(gh issue comment:*)
---

# post-spec

Push a finished spec draft from `.scratch/` up to GitHub as the canonical `[Spec]` issue.
After this runs, **the issue is the source of truth** — the local draft is no longer authoritative.

## Process

1. **Resolve the draft.** The argument is the path to a `.scratch/` markdown file. If omitted, use the
   most recent `.scratch/*.md` and confirm with the user before posting.

2. **Read the frontmatter and validate.** Parse the YAML metadata block at the top of the draft (a fenced
   ` ```yaml ` block — not a bare `---` block, which GitHub renders as a giant heading in an issue) and
   extract `title` and `approvers`.
   Refuse to post and report what's wrong if any of these hold:
   - `title` is empty or still the `<short descriptive title>` placeholder.
   - `approvers` is empty or still contains `<github-handle>` placeholders.
   - Any required body section is missing or empty (Acceptance Criteria especially — it's the e2e contract).

   A spec posts only when it's actually fillable; posting placeholders wastes reviewers' time.

3. **Create the issue.** Title is the frontmatter `title` with a `[Spec] ` prefix; body is the draft
   verbatim (the ` ```yaml ` metadata block included — it's machine-readable metadata that renders cleanly).
   Label `spec` + `needs-approval`.
   Assign the `approvers` as assignees:

   ```sh
   gh issue create \
     --title "[Spec] <title>" \
     --body-file <draft-path> \
     --label "spec,needs-approval" \
     --assignee "<approver1>,<approver2>"
   ```

   (Add `--repo <owner>/<repo>` if not in the target repo.)

4. **Handle un-assignable approvers.** `gh` errors if an approver isn't a repo collaborator. If assignment
   fails, retry the create **without** `--assignee`, then post a comment `@`-mentioning the approvers so they
   are still notified. Report which approvers couldn't be assigned.

5. **Report.** Print the new issue number and URL. Note the next step: reviewers run `review-spec`; the author
   does **not** set `approved` — that's the Action, triggered by `/approve` or 👍.

## Notes

- `post-spec` never sets `approved`. It only ever applies `needs-approval`.
- The `.scratch` draft stays gitignored and is not committed. Drift is avoided by always re-pulling the
  issue body before later edits (`address-comments`) or implementation.

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

2. **Read the frontmatter and validate.** Parse the draft's `---` YAML frontmatter and extract `title` and
   `approvers`.
   Refuse to post and report what's wrong if any of these hold:
   - `title` is empty or still the `<short descriptive title>` placeholder.
   - `approvers` is empty or still contains `<github-handle>` placeholders.
   - Any required body section is missing or empty (Acceptance Criteria especially — it's the e2e contract).

   A spec posts only when it's actually fillable; posting placeholders wastes reviewers' time.

3. **Fence the frontmatter for GitHub.** A bare `---` frontmatter block renders as a giant heading inside a
   GitHub issue. Build the issue body from the draft by converting *only the leading frontmatter delimiters*
   to a fenced ` ```yaml ` block: the opening `---` becomes a ` ```yaml ` line and the closing `---` becomes
   a ` ``` ` line. Everything else — the YAML lines themselves and the whole body below — stays byte-for-byte.
   The local `.scratch/` draft keeps its standard `---` frontmatter; only the posted body is fenced. A
   reliable one-liner (converts just the first block, leaving any `---` rules in the body alone):

   ````sh
   awk 'NR==1 && $0=="---"{print "```yaml"; f=1; next}
        f && $0=="---"{print "```"; f=0; next} {print}' <draft-path> > <body-path>
   ````

4. **Create the issue.** Title is the frontmatter `title` with a `[Spec] ` prefix; body is the fenced
   `<body-path>` from step 3. Label `spec` + `needs-approval`. Assign the `approvers` as assignees:

   ```sh
   gh issue create \
     --title "[Spec] <title>" \
     --body-file <body-path> \
     --label "spec,needs-approval" \
     --assignee "<approver1>,<approver2>"
   ```

   (Add `--repo <owner>/<repo>` if not in the target repo.)

5. **Handle un-assignable approvers.** `gh` errors if an approver isn't a repo collaborator. If assignment
   fails, retry the create **without** `--assignee`, then post a comment `@`-mentioning the approvers so they
   are still notified. Report which approvers couldn't be assigned.

6. **Report.** Print the new issue number and URL. Note the next step: reviewers run `review-spec`; the author
   does **not** set `approved` — that's the Action, triggered by `/approve` or 👍.

## Notes

- `post-spec` never sets `approved`. It only ever applies `needs-approval`.
- The `.scratch` draft stays gitignored and is not committed. Drift is avoided by always re-pulling the
  issue body before later edits (`address-comments`) or implementation.

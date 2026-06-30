---
name: slice-to-subissues
description: Slice an approved [Spec] issue into dependency-ordered, unit-tested [Task] sub-issues. Use when the user wants to decompose a spec, break an approved design into tasks, or kick off implementation after approval. Gates on the approved label first and refuses unapproved specs.
argument-hint: <issue-number-or-url>
allowed-tools:
  - Skill(check-approval)
  - Read
  - Write
  - Bash(gh issue view:*)
  - Bash(gh issue create:*)
  - Bash(gh issue edit:*)
---

# slice-to-subissues

Decompose an **approved** `[Spec]` issue into dependency-ordered `[Task]` sub-issues, each unit-tested and
back-linked to the parent. This is the author-side step that runs **after approval** and turns a frozen
design into grabbable work. The spec's Acceptance Criteria stay the e2e contract — tasks carry **unit tests
only** and do not each re-prove the behavior end-to-end. (Arc-native; the decomposition mindset borrows from
Matt Pocock's `to-issues`.)

## Process

1. **Gate on approval first.** Delegate to **`check-approval <issue>`**. If the verdict is not APPROVED,
   refuse and stop — report the labels it found so the author knows where the spec sits. Trust only that
   verdict; never infer approval from a `/approve` comment or 👍. Slicing an unapproved spec builds against
   a moving target.

2. **Pull the canonical spec body.** Re-pull from the issue — the issue is the source of truth, not any
   stale `.scratch/` draft:

   ```sh
   gh issue view <issue> --json number,title,body,labels
   ```

   (Add `--repo <owner>/<repo>` if not in the target repo.) The spec is identified by its issue number;
   read the design sections you'll decompose against.

3. **Decompose into dependency-ordered slices.** Break the spec's single behavior into the smallest set of
   tasks that each deliver a coherent unit of it, threaded through the layers it touches. Order them by
   dependency and capture each task's prerequisites as `blocked-by`. Aim for tasks a single agent can pick
   up and unit-test in isolation — the spec already owns the end-to-end proof.

4. **Confirm the breakdown with the author.** Present the proposed tasks as a numbered list — title and
   `blocked-by` per task. Ask whether the granularity and dependencies are right; iterate until the author
   approves. Don't create issues against an unconfirmed split.

5. **Fill one `task.md` per slice.** Build each task body from this skill's `task.md` template, following
   the template's own section guidance (don't restate it here). Set the frontmatter (standard `---` YAML in
   the local draft): `title`, `spec-issue` (the parent issue number), `blocked-by` (issue numbers — filled as
   blockers are created in step 6), and leave `verified-by: unit`. Back-link the **Parent** section to the
   spec issue by number. Tasks have no own id — each task's GitHub issue number is its identity.

6. **Push tasks in dependency order.** Create blockers first so you can reference real issue numbers in
   dependents' `blocked-by`. For each task, first **fence its frontmatter** the same way `post-spec` does —
   convert the leading `---` frontmatter delimiters to a ` ```yaml ` block so the issue renders cleanly
   (the local draft keeps its `---`); everything else stays byte-for-byte:

   ````sh
   awk 'NR==1 && $0=="---"{print "```yaml"; f=1; next}
        f && $0=="---"{print "```"; f=0; next} {print}' <task-path> > <body-path>
   gh issue create \
     --title "[Task] <title>" \
     --body-file <body-path> \
     --label "task"
   ````

   (Add `--repo <owner>/<repo>` if not in the target repo.) After a blocker is created, fill its real issue
   number into the dependents' `blocked-by` before creating them.

7. **Backfill the spec's `tasks:` frontmatter.** Re-pull the spec body (it may have changed since step 2),
   set `tasks:` to the list of created issue numbers (edit the `tasks:` line inside the ` ```yaml ` block —
   leave the rest of the body untouched), and write it back with `gh issue edit <issue> --body-file
   <updated>`. This is requirement-6 linkage — the spec now points at the work that implements it.

8. **Report.** Print the created `[Task]` issue numbers and URLs in dependency order, and confirm the spec's
   `tasks:` was backfilled.

## Notes

- Approval is non-negotiable: no `check-approval` APPROVED verdict, no slicing.
- Never set or remove the `approved` label, and never modify the parent spec's design body — only its
  `tasks:` frontmatter.
- Each task is unit-scoped. If you feel a task needs its own end-to-end proof, the slice is probably too
  large or the e2e belongs in the spec.

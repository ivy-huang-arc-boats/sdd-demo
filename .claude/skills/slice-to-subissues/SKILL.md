---
name: slice-to-subissues
description: Slice an approved [Spec] issue into dependency-ordered, unit-tested [Task] sub-issues. Use when the user wants to decompose a spec, break an approved design into tasks, or kick off implementation after approval. Gates on the approved label first and refuses unapproved specs.
argument-hint: <issue-number-or-url>
allowed-tools:
  - Skill(check-approval)
  - Read
  - Write
  - Bash(gh issue view:*)
  - Bash(bash skills/slice-to-subissues/create-task.sh:*)
  - Bash(bash .claude/skills/slice-to-subissues/create-task.sh:*)
  - Bash(bash skills/slice-to-subissues/backfill-tasks.sh:*)
  - Bash(bash .claude/skills/slice-to-subissues/backfill-tasks.sh:*)
---

# slice-to-subissues

Decompose an **approved** `[Spec]` issue into dependency-ordered `[Task]` sub-issues, each unit-tested and
back-linked to the parent. This is the author-side step that runs **after approval** and turns a frozen
design into grabbable work. The spec's Acceptance Criteria stay the e2e contract — tasks carry **unit tests
only** and do not each re-prove the behavior end-to-end. (Arc-native; the decomposition mindset borrows from
Matt Pocock's `to-issues`.)

The **decomposition is yours** — judgment this skill can't script. The deterministic mechanics around it are
scripted, in this skill's directory: **`create-task.sh`** (fence a task draft, create the `[Task]` issue, and
link it as a native GitHub sub-issue of the spec) and **`backfill-tasks.sh`** (set the spec's `tasks:` list).
Decide the slices and `blocked-by` yourself; let the scripts publish them the same way every time.

## Process

1. **Gate on approval first.** Delegate to **`check-approval <issue>`**. If the verdict is not APPROVED,
   refuse and stop — report the labels it found so the author knows where the spec sits. Trust only that
   verdict; never infer approval from a `/approve` comment. Slicing an unapproved spec builds against a
   moving target.

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

6. **Create tasks in dependency order, via the script.** Create blockers first so you can fill their real
   issue numbers into dependents' `blocked-by` before those drafts are posted. For each task draft, run
   (bundled path: `.claude/skills/slice-to-subissues/create-task.sh`):

   ```sh
   bash skills/slice-to-subissues/create-task.sh <parent-spec-#> <task-draft-path> [owner/repo]
   ```

   It fences the draft's frontmatter, creates the `[Task]` issue with the `task` label, links it as a native
   sub-issue of the parent spec, and prints the new issue number — capture it for the next task's `blocked-by`.
   *(`DRY_RUN=1 bash …` previews the fenced body and skips creation.)*

7. **Backfill the spec's `tasks:` list, via the script.** Once all tasks exist:

   ```sh
   bash skills/slice-to-subissues/backfill-tasks.sh <spec-#> <n1,n2,n3,...> [owner/repo]
   ```

   It re-pulls the canonical spec body and edits **only** the `tasks:` line inside its ` ```yaml ` block,
   leaving the design body untouched — requirement-6 linkage, so the spec points at the work that implements it.

8. **Report.** Print the created `[Task]` issue numbers and URLs in dependency order, and confirm the spec's
   `tasks:` was backfilled.

## Notes

- Approval is non-negotiable: no `check-approval` APPROVED verdict, no slicing.
- Never set or remove the `approved` label, and never modify the parent spec's design body — only its
  `tasks:` frontmatter.
- Each task is unit-scoped. If you feel a task needs its own end-to-end proof, the slice is probably too
  large or the e2e belongs in the spec.

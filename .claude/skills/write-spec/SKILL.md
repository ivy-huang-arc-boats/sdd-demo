---
name: write-spec
description: Draft a Spec-Driven Development spec into a gitignored .scratch/ file. Use when the user wants to write up a feature or design as a [Spec], or turn resolved decisions into a spec draft. Produces a draft only — post-spec publishes it.
---

# write-spec

Turn a feature intent plus the codebase into a fillable `[Spec]` draft in `.scratch/`, following this
skill's `spec.md` template exactly. The output is a **draft file, never a posted issue** — publishing is
`post-spec`'s job.

## Process

1. **Understand the intent and the code.** Get the feature the user wants, then explore the modules it
   touches so the spec is concrete. Use the project's domain glossary vocabulary throughout and respect
   existing ADRs in the area.

2. **Sharpen first if the design is fuzzy.** If decisions aren't settled, run **`grill-with-docs`**.
   Skip it only when the design is already resolved (e.g. you just finished grilling). Don't draft on
   top of unanswered questions.

3. **Pin the seam.** Sketch where the feature is exercised end-to-end. Prefer an existing seam; if a new
   one is needed, propose it at the highest point possible — **the ideal is a single seam**, and that
   seam is the spec's e2e contract. Confirm it matches the user's expectations before drafting.

4. **Draft into `.scratch/`** from this skill's `spec.md` template (create `.scratch/` if absent — it's
   gitignored).
   Name the file with a slug, e.g. `.scratch/email-login.md` — the draft has no id yet; the GitHub issue
   number becomes its identity once `post-spec` publishes it.

   Fill the **frontmatter**, resolving each value rather than leaving the template's placeholder:
   `title`, `authors` (default the current user), `approvers` (ask if unstated), `target-milestone` (ask if
   unstated), `supersedes` (issue numbers of any specs this replaces), and leave `tasks: []`. The draft has
   no id field — the GitHub issue number is the canonical id once posted.

   Fill **every body section per the template's own guidance** — no placeholders or HTML comments left
   behind. These four carry the most weight and are the easiest to answer uselessly, so spend the effort here:
   - **Interfaces / Data Models / Constraints / Examples** — concrete enough to implement without a
     follow-up conversation.
   - **Alternatives Considered** — each rejected option *and why*.
   - **Seams / Testing Decisions** — the seam from step 3, described as external behavior.
   - **Acceptance Criteria** — the e2e contract as a checklist.

5. **Report.** Print the draft path and what's filled vs. still needs the author. The next step is to
   review the draft and run **`post-spec <path>`**.

## Notes

- Draft only: this skill never calls `gh`, never creates an issue, never applies a label.
- Once `post-spec` publishes the draft, the **issue** is the source of truth — re-pull from it before
  later edits; don't trust the stale `.scratch/` copy.

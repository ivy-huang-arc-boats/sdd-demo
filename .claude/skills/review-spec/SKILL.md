---
name: review-spec
description: Critique a posted [Spec] issue's design against the SDD rubric and post findings as quoted comments. Use when the user is reviewing a spec issue, asks for spec feedback, or wants to flag design gaps before approval. Reviewer-facing; never approves.
argument-hint: <issue-number-or-url>
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(gh issue view:*)
  - Bash(gh issue comment:*)
  - Bash(gh issue edit:*)
---

# review-spec

Review a posted `[Spec]` issue's **design** against the SDD rubric and leave findings the author can act
on. This is design critique — does the spec carry enough reviewable context to build against — **not**
line-by-line code review. Findings go up as **quoted comments** so `address-comments` can locate exactly
what each concern refers to. This skill **never approves**; approval is the Action's job.

## Process

1. **Pull the issue body.** It is the source of truth — review what's posted, not a local draft:

   ```sh
   gh issue view <issue> --json number,title,state,body,labels
   ```

   (Add `--repo <owner>/<repo>` if not in the target repo.) Resolve the argument to an issue number/URL;
   ask if none was given.

2. **Ground the critique in reality.** Read the project's domain glossary and ADRs (per `domain-modeling`'s
   conventions — `CONTEXT.md` / `CONTEXT-MAP.md` and `docs/adr/`) and skim the code the spec touches, so
   findings cite what actually exists — wrong vocabulary, a contradicted ADR, an interface that doesn't
   match the code — not just internal polish.

3. **Critique against the rubric.** Each item is a check with a concrete failure mode; a finding is anything
   that would leave an agent guessing or a reviewer unable to validate the reasoning:
   - **Sufficient context** — are interfaces, data models, constraints, and examples concrete enough to
     implement without a follow-up conversation? Flag hand-waving and TBDs.
   - **Reviewable decision** — is the chosen approach stated *with rationale*, and are rejected alternatives
     captured *with why*? A decision with no visible reasoning can't be validated.
   - **Testable contract** — is each Acceptance Criterion observable and checkable, and does it match the
     declared seam? Flag criteria that can't be proven pass/fail.
   - **Explicit boundaries** — is Out-of-Scope stated, so the spec's edges aren't left ambiguous?
   - **Grounded** — does it use glossary terms correctly, respect existing ADRs, and match code reality
     (step 2)?

4. **Post each finding as a quoted comment.** One comment per finding, formatted so `address-comments` can
   key off it — a blockquote of the exact spec excerpt, then the concern:

   ```sh
   gh issue comment <issue> --body '> <excerpt from the spec body>

   <the concern, and what would resolve it>'
   ```

   The quote must be a verbatim slice of the issue body. Completion criterion: **every finding is a quote +
   concern**; no free-floating critique that the author can't trace back to a location.

5. **Set `question` when concerns exist.** If you filed any findings, flag the issue so the author knows it
   needs a pass:

   ```sh
   gh issue edit <issue> --add-label question
   ```

   If the design is clean, file nothing and add no label — just report that it's solid (a clean review is
   still not an approval).

6. **Report.** Summarize the findings posted and whether `question` was set. Note the next step: the author
   runs `address-comments`; approval remains the reviewer's separate `/approve`, gated by the Action.

## Notes

- **Never approves.** This skill files concerns and sets `question`; it never sets `approved` and never closes
  the issue — approval is the Action's, signalled by a reviewer's `/approve` comment.
- Read the issue body fresh each run; don't review a stale `.scratch/` draft.
- Quote excerpts verbatim — a paraphrased quote breaks `address-comments`' ability to locate the spot.
- Design critique, not code review: judge whether the spec is a sufficient, reviewable contract, not the
  implementation that doesn't exist yet.

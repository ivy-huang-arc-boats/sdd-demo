---
name: address-comments
description: Work through reviewer comments on a [Spec] issue with the author — pull the comments, disposition each one-at-a-time (accept/reject/modify), edit the issue body in place, post a quoted reply per comment, clear the question label, and prompt reviewers to re-approve. Use when a reviewer has flagged concerns on a spec and the author needs to respond.
argument-hint: <issue-number-or-url>
allowed-tools:
  - Skill(pull-comments)
  - Read
  - Write
  - Bash(gh issue view:*)
  - Bash(gh issue edit:*)
  - Bash(gh issue comment:*)
---

# address-comments

Run the author-side loop after a reviewer leaves concerns on a `[Spec]` issue: triage every comment with
the human, fold accepted changes into the issue body, and hand the spec back for re-approval. The
**GitHub issue is canonical** — edits land on the live issue, never a `.scratch/` copy.

## Process

1. **Pull the comments.** Run **`pull-comments <issue>`** to fetch the reviewer's comments — do not
   re-implement `gh` comment-fetching. Work only from the comment **bodies** and their `> quoted`
   excerpts; approval is signaled by `/approve` comments and is not your concern here. Build the working
   list of every comment that needs a disposition.

2. **Re-pull the canonical issue body.** Before any edit, fetch the live body so you edit the current
   text, not a stale copy:

   ```sh
   gh issue view <issue> --json number,title,body,labels
   ```

   (Add `--repo <owner>/<repo>` if not in the target repo.)

3. **Triage ONE comment at a time.** This is the heart of the skill — resist batching. For each comment,
   present it to the author and settle a single disposition with a rationale:
   - **accept** — the change is warranted; note the exact edit to make.
   - **reject** — the comment stands but the spec stays; record why.
   - **modify** — a third path; record what you'll do instead and why.

   Do not move to the next comment until the current one has a disposition. Track which comments are done
   so none is skipped.

4. **Apply accepted edits to the issue body in place.** For each `accept`/`modify` that changes the spec,
   edit the canonical body (built from the step-2 re-pull) and push it:

   ```sh
   gh issue edit <issue> --body-file <updated-body>
   ```

   `reject` dispositions change no text — they're recorded only as a reply (step 5).

5. **Post a quoted reply per comment.** For each comment, post a reply that quotes the reviewer's point and
   states the disposition, so each disposition is locatable:

   ```
   > <the reviewer's point, quoted>

   Accepted — <what changed in the body>.   (or: Rejected — <why> / Modified — <what instead, why>)
   ```

   One reply per comment, so the reviewer can map every concern to its outcome.

6. **Clear `question` once EVERY comment is dispositioned.** Verify the step-1 list is fully exhausted —
   every comment has a disposition (step 3) and a quoted reply (step 5). Only then:

   ```sh
   gh issue edit <issue> --remove-label question
   ```

   If any comment is still open, do not clear the label.

7. **Prompt re-approval.** Post ONE summary comment `@`-mentioning the reviewers, briefly listing what
   changed, asking them to re-review and re-run `/approve`. Report the issue URL and the
   accept/reject/modify tally.

## Notes

- Never approves. This skill only ever **removes** `question`; the `approved` label is set solely by the
  approval Action, triggered by a reviewer's `/approve`.
- Edits target the **live issue body** every time — re-pull (step 2) before editing; never edit from a
  `.scratch/` draft, which is stale once `post-spec` published.

---
name: check-approval
description: Check whether a [Spec] issue passed the approval gate (has the approved label). Use when the user asks if a spec is approved, or when slice-to-subissues needs to confirm approval before decomposing.
argument-hint: <issue-number-or-url>
allowed-tools: Bash(gh issue view:*)
---

# check-approval

Report whether a spec issue has passed the approval gate. This is the **machine-readable gate** an agent
checks before treating a spec as buildable — the whole point of the `approved` label.

## Process

1. **Resolve the issue.** The argument is an issue number or URL. If none was given, ask for one.

2. **Read labels and state:**

   ```sh
   gh issue view <issue> --json number,title,labels
   ```

   (Add `--repo <owner>/<repo>` if not in the target repo.)

3. **Decide:**
   - `approved` = the `labels` array contains a label named **`approved`**.
   - An approved spec is **frozen** (its body is immutable), but the **issue stays open** — freezing is about
     the content, not closing the issue. Do not treat `state` as the approval signal.

4. **Report a clear verdict:**
   - **APPROVED** — `approved` label present. The spec is frozen (immutable body); safe to proceed
     (e.g. `slice-to-subissues` may run).
   - **NOT APPROVED** — list the labels actually present (e.g. `needs-approval`, `question`) so the caller
     knows where in the lifecycle the spec sits.

## Notes

- Read-only. Never applies or removes the `approved` label — that is reserved for the approval Action.
- Trust **only** the label. Do not infer approval from a `/approve` comment or a 👍 reaction; those are
  signals the Action consumes, not proof on their own.

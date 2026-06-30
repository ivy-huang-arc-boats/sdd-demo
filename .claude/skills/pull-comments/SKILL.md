---
name: pull-comments
description: Fetch the comments on a [Spec] issue as structured, locatable text. Use when the user wants to see what reviewers said on a spec, or when address-comments needs the comments to triage.
argument-hint: <issue-number-or-url>
allowed-tools: Bash(gh issue view:*)
---

# pull-comments

Fetch the comments on a GitHub issue and present them as structured, locatable text.
This is a thin, deterministic `gh` wrapper — it reads only, never writes.

## Process

1. **Resolve the issue.** The argument is an issue number or URL. If none was given, ask for one.

2. **Fetch** the issue and its comments in one call:

   ```sh
   gh issue view <issue> --json number,title,state,labels,comments
   ```

   (Add `--repo <owner>/<repo>` if not running inside the target repository.)

3. **Render** the result for a human or the calling skill. Show, in order:

   - **Header:** `#<number> <title>` · state · labels (flag `needs-approval`, `question`, `approved`).
   - **Each comment**, numbered, with:
     - author + `createdAt`
     - the comment **body verbatim**, preserving any `> blockquote` lines (reviewers quote the spec section
       they're flagging, so the quote is how the author locates what to fix)

4. **Surface approval signals, but do not act on them.** Note any `/approve` comment as an approval *signal*.
   Actual approval is the `approved` label set by the Action — checked by `check-approval`, never inferred here.

## Notes

- Read-only. This command does not edit, reply, resolve, or label anything.

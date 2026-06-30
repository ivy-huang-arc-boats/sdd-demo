---
name: grill-with-docs
description: Grill a fuzzy feature or design into grounded decisions, anchored in the local glossary, ADRs, and code. Use when the user wants to stress-test a design before writing it up, or when write-spec needs open questions resolved first.
---

# grill-with-docs

Sharpen a half-formed idea into decisions grounded in what already exists — the glossary, the ADRs,
the code — before any spec is written. Composes two existing skills: load the local context first,
then lean on **`grilling`** for the interview and **`domain-modeling`** to capture decisions as they land.

Runnable standalone to think a design through; `write-spec` calls it as its first step so drafting
starts from resolved decisions, not a blank page.

## Process

1. **Load the local context.** Before asking anything, read what the project already knows so the
   interview builds on it rather than relitigating it:
   - **Glossary & ADRs** — the project's domain vocabulary and recorded decisions, per `domain-modeling`'s
     conventions (`CONTEXT.md` / `CONTEXT-MAP.md` and `docs/adr/`). Use these terms exactly.
   - **Seed docs** — anything the user `@`-mentioned: a wiki page, a Slack export, a rough doc.
   - **Code** — the modules the feature touches, so questions are answerable from the repo.

   Summarize back what you found so the user can correct a wrong starting point before the grilling begins.

2. **Grill.** Hand the interview to **`grilling`**.

3. **Capture decisions as they land.** Use **`domain-modeling`** throughout, not at the end: sharpen
   glossary terms in `CONTEXT.md` inline, and record the decisions that warrant it as ADRs.

4. **Report.** Summarize what's now settled and what's still open, so the user — or `write-spec` — can
   carry it into a draft.

## Notes

- Output is sharpened decisions plus any glossary/ADR updates. This skill **writes no spec and posts
  nothing** — `write-spec` turns the decisions into a draft.

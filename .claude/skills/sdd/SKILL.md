---
name: sdd
description: Route to the right Spec-Driven Development skill for the current stage. Use when the user wants to start the SDD workflow, asks which SDD skill or command to reach for, or isn't sure what the next step is for a spec.
---

# sdd

Spec-Driven Development at Arc: a human-authored, human-approved **spec** drives AI implementation. The
spec is the single source of truth, it lives as a **GitHub issue**, and approval is a machine-readable
gate an agent can trust. This skill is the **router** — it points to the skill or command for whatever
stage you're at.

## First: is this spec-worthy?

SDD earns its ceremony only when there's **design risk worth pinning down before an agent builds**.
Trivial work shouldn't be specced — it just routes people around the workflow. Before pointing anywhere,
size the work against this test and **recommend**; the author makes the final call (don't gate silently).

| Skip SDD — just build it / open a plain issue | Write a spec |
|-----------------------------------------------|--------------|
| One layer, one file, mechanical               | Threads data → logic → API |
| Easily reversible                             | Migration, shared contract, or hard to undo |
| One obvious way to do it                      | Real choices + alternatives worth recording |
| No blast radius                               | Touches auth, security, money, or a public interface |

**Any one** right-column hit → spec it. All left-column → skip SDD. Mixed or unsure → surface the tension
and ask the author rather than deciding for them. Only once it's spec-worthy, route to the stage below.

## The workflow

Each row is a stage; reach for the skill named in it. **Commands** are argument-taking `gh` wrappers you can
drive by slash (`/pull-comments 123`); `/post-spec` is **human-only** (the deliberate publish gate), while the
others stay model-reachable so skills can delegate to them. **Skills** are reached by name or fire on their own.

| Stage | Reach for | Kind |
|-------|-----------|------|
| Sharpen a fuzzy design into grounded decisions | `grill-with-docs` | skill |
| Draft the spec into `.scratch/` | `write-spec` | skill |
| Post the draft as a `[Spec]` issue (`needs-approval`, assign approvers) | `/post-spec` | command |
| **(reviewer)** Critique a posted spec, leave quoted comments | `review-spec` | skill |
| See the comments on a spec issue | `/pull-comments` | command |
| Address review comments — triage, edit, reply, re-prompt | `address-comments` | skill |
| Check whether a spec passed the approval gate | `/check-approval` | command |
| Slice an **approved** spec into `[Task]` sub-issues | `slice-to-subissues` | skill |

Author path: `grill-with-docs` → `write-spec` → `/post-spec` → *(reviewers)* → `address-comments` →
*(approval)* → `slice-to-subissues`. Reviewer path: `/pull-comments` → `review-spec`.

## Rules that hold at every stage

- **The issue is canonical.** Once `/post-spec` publishes it, re-pull from the issue before any edit —
  never trust a stale `.scratch/` draft.
- **Approval is comments-only and Action-set.** A reviewer signals with an `/approve` comment; the
  `approved` label is applied only by a (deferred) GitHub Action. No skill or human sets it by hand, and
  no skill infers approval from anything but the label.
- **Approved means frozen.** An approved spec's body is immutable; changes are new specs that link back
  via `supersedes`. The issue stays open.

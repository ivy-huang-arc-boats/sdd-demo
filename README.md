# sdd-demo — Spec-Driven Development, end to end

A **self-contained sandbox** for learning Spec-Driven Development (SDD) at Arc. Clone it, open it in
[Claude Code](https://claude.com/claude-code), and walk one feature from a fuzzy idea to dependency-ordered,
ready-to-build tasks — without touching any real product code.

> **The idea.** When agents write most of the code, line-by-line review stops scaling. So we move review
> *upstream* — onto the **design**. A human-authored, human-approved **spec** becomes the single source of
> truth the agent builds against. The spec lives as a **GitHub issue**, and approval is a machine-readable
> gate an agent can trust.

## What's in here

| Path | What it is |
|------|------------|
| `.claude/skills/` | The full SDD skill suite, bundled and ready to run in this repo |
| `labels/labels.yml` | The label vocabulary the skills key off (`spec`, `task`, `needs-approval`, `question`, `approved`) |
| `docs/sdd-onboarding-deck.md` | The 20-minute team walkthrough (Marp slides) |
| `src/` + `docs/glossary.md` + `docs/adr/` | A tiny fake product — **"Atlas"** — so the worked example has real code, terms, and decisions to reference |

This repo intentionally ships **no build tooling**. `src/` is a thin skeleton that exists only to give the
spec something concrete to point at — interfaces, seams, a glossary. The product of SDD is the *spec and its
tasks*, not running code.

## The worked example, live on GitHub

The issues in this repo's tracker **are** the demo. One feature taken all the way through:

> **"Members can log in with email and password."** — register, log in, stay signed in for 30 days.

Browse the tracker and you'll see the whole loop as a browsable artifact:

```
[Spec] Members can log in with email and password   ← the design (approved + frozen)
 ├── [Task] Credential data model + migration
 ├── [Task] Auth service: hash, verify, issue session
 ├── [Task] POST /login + /logout endpoints          (blocked-by the two above)
 └── [Task] Login form + "stay signed in"            (blocked-by endpoints)
```

The spec issue carries a review comment, the author's reply, and an `/approve` — so you can read how a spec
gets sharpened and gated, not just the final state.

## The workflow

```
grill-with-docs → write-spec → /post-spec → ‹review› → address-comments → ‹approve› → slice-to-subissues
                                                ↑                              ↑
                                          /pull-comments                 /check-approval
                                          review-spec
```

| Stage | You want to… | Reach for | Kind |
|-------|--------------|-----------|------|
| Sharpen | Pin down a fuzzy design | `grill-with-docs` | skill |
| Draft | Write the spec into `.scratch/` | `write-spec` | skill |
| Publish | Post the draft as a `[Spec]` issue | `/post-spec` | 🔒 human-only |
| Review | Critique someone's spec | `review-spec` | skill |
| Read review | See the comments | `/pull-comments` | command |
| Respond | Address the review | `address-comments` | skill |
| Approve | Signal approval | comment `/approve` | gate |
| Check | Is it approved? | `/check-approval` | command |
| Slice | Break it into tasks | `slice-to-subissues` | skill |
| Lost? | Not sure where you are | `/sdd` | router |

🔒 `/post-spec` is the only human-only step — the deliberate "publish to GitHub" gate. Everything else the
agent can also run on its own, and skills delegate to the commands.

## Try it yourself

1. Open this repo in Claude Code.
2. Run `/sdd` and tell it what you want to build (try something small but with real design risk).
3. Follow where it routes you. Drafts land in `.scratch/`; nothing hits GitHub until **you** run `/post-spec`.

## The rules that hold at every stage

- **The issue is canonical.** After `/post-spec`, always re-pull from the issue before editing. Never trust
  a stale `.scratch/` draft.
- **Approval is comments-only and Action-set.** `/approve` is the signal; the `approved` label is applied
  only by a GitHub Action *(deferred — the demo applies it by hand to show the end state, and says so)*. No
  hand-setting in real use, no inferring approval from 👍.
- **Approved = frozen.** An approved spec's body is immutable; changes are new specs that `supersedes` the
  old one. The issue stays open.

See [`docs/sdd-onboarding-deck.md`](docs/sdd-onboarding-deck.md) for the full walkthrough.

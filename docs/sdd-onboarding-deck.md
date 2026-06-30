---
marp: true
theme: uncover
paginate: true
backgroundColor: #fff
color: #1b1b1b
style: |
  section {
    font-size: 26px;
    justify-content: flex-start;
    padding: 50px 70px;
  }
  section.lead { justify-content: center; text-align: center; }
  h1 { color: #0b5fff; font-size: 46px; }
  h2 { color: #0b5fff; font-size: 34px; border-bottom: 2px solid #e6ecff; padding-bottom: 6px; }
  strong { color: #0b3bdb; }
  code { background: #f4f6fb; color: #b3208a; padding: 1px 6px; border-radius: 4px; }
  pre { background: #0f172a; border-radius: 8px; font-size: 18px; }
  pre code { background: transparent; color: #e2e8f0; }
  blockquote {
    background: #f4f8ff; border-left: 6px solid #0b5fff;
    padding: 12px 18px; font-style: normal; border-radius: 4px;
    font-size: 22px;
  }
  table { font-size: 21px; }
  th { background: #0b5fff; color: #fff; }
  .small { font-size: 19px; color: #555; }
  .pill { background:#e6ecff; color:#0b3bdb; padding:2px 10px; border-radius:12px; font-size:18px; }
---

<!-- _class: lead -->

# Spec‑Driven Development
### How we design before we build at Arc

<br>

<span class="pill">Atlas · ERP / MES / MRP</span>

<span class="small">A 20‑minute team walkthrough — one feature, every stage</span>

---

<!-- _class: lead -->

## Why we're doing this

AI agents write code **faster than anyone can review it.**

Line‑by‑line review stops scaling.

So we move the review **upstream** — to the **design**.

> Approve the *spec*, and the agent has a contract to build against.
> Humans stay aligned on **what** is being built and **why**.

---

## What a spec has to do

A spec isn't a doc you write and forget. It has **six jobs**:

1. **Give the agent enough context** — interfaces, data models, constraints, examples
2. **Capture the decision + rationale** — and the alternatives you rejected, and why
3. **Be the implementation contract** — what code is checked against
4. **Be the approval gate** — auditable, machine‑readable: *is this approved? yes/no*
5. **Freeze once approved** — immutable, so context can't shift under the build
6. **Stay linked to the code** — the spec points at the work that implements it

<span class="small">Every skill in this workflow exists to satisfy one of these six.</span>

---

## The whole thing lives in GitHub Issues

No new tool. A spec **is an issue**. A task **is a sub‑issue**.

```
#142 [Spec] Members can log in with email + password      ← the design
 ├── #143 [Task] Data model + migration for credentials
 ├── #144 [Task] Auth service: hash, verify, session
 ├── #145 [Task] POST /login + /logout endpoints
 └── #146 [Task] Login form + "stay signed in"
```

The **issue number is the only id.** Identity and status are read **live**
from GitHub — never copied into a local file that would drift.

---

## The lifecycle at a glance

| Stage | Who | Reach for | Kind |
|------|-----|-----------|------|
| Sharpen a fuzzy idea | Author | `grill-with-docs` | skill |
| Draft the spec | Author | `write-spec` | skill |
| Publish it | Author | `/post-spec` | 🔒 command |
| Critique it | Reviewer | `review-spec` | skill |
| See the comments | anyone | `/pull-comments` | command |
| Respond to review | Author | `address-comments` | skill |
| Approve | Reviewer | `/approve` comment → Action | gate |
| Is it approved? | anyone | `/check-approval` | command |
| Break into tasks | Author | `slice-to-subissues` | skill |

<span class="small">🔒 = human‑only. Everything else the agent can also run on its own.</span>

---

<!-- _class: lead -->

# The worked example

We'll take **one feature** all the way through:

> **"Members can log in with email and password."**
> Register, log in, stay signed in for 30 days. — *Atlas Q3*

Author: **you** · Approvers: **@rohan, @mei**

---

## Stage 1 — Sharpen  ·  `grill-with-docs`

*Optional. Use it when the design is still fuzzy.* Grounds you in the
glossary, ADRs, and code **before** a blank page.

> `/grill-with-docs` Members should log in with email + password for Atlas.
> Unsure on: session length, password reset, account lockout.

**What happens:** it loads local context, hands you to the `grilling`
interview, and records decisions as glossary terms / ADRs.

**Output:** sharpened decisions. **No spec, nothing posted yet.**

<span class="small">Skip it only when the design is already resolved (e.g. you just finished grilling).</span>

---

## Stage 2 — Draft  ·  `write-spec`

Turns intent + the codebase into a **fillable draft** in `.scratch/`.

> `/write-spec` email/password login for Atlas — members register, log in,
> stay signed in 30 days. Approvers: @rohan, @mei. Milestone: Atlas Q3.

**What happens:** explores the modules it touches, pins the **end‑to‑end seam**,
fills frontmatter + every body section from the `spec.md` template.

**Output:** `.scratch/email-login.md` — a **draft file, not an issue.**

<span class="small">You stay in control of when it becomes canonical. That's the next stage.</span>

---

## Stage 2 — what the draft looks like

```yaml
title: Members can log in with email and password
authors: [ivy-huang]
approvers: [rohan, mei]      # expected reviewers — not proof of approval
target-milestone: Atlas Q3
supersedes: []
tasks: []                    # backfilled after slicing
```

Body sections — the ones that carry the weight:

- **Interfaces / Data Models / Constraints / Examples** — concrete enough to build, no follow‑up needed
- **Alternatives Considered** — each rejected option *and why*
- **Seams / Testing Decisions** — the e2e behavior
- **Acceptance Criteria** — the e2e contract, as a checklist

---

## Stage 3 — Publish  ·  `/post-spec`  🔒

The one **human‑only** step — the deliberate publish gate. The agent
will never fire this on its own.

> `/post-spec .scratch/email-login.md`

**What happens:** validates the draft is actually filled (no placeholders),
creates the issue, applies labels, assigns the approvers from frontmatter.

**Output:**
```
✓ Created #142  [Spec] Members can log in with email and password
  labels: spec, needs-approval   assignees: @rohan @mei
  https://github.com/arc/atlas/issues/142
```

**From now on, the issue is the source of truth — not the `.scratch` draft.**

---

## Stage 4 — Review  ·  `review-spec`  <span class="pill">reviewer</span>

Critiques the **design** against the six‑job rubric — *does this carry
enough reviewable context to build against?* Not code review.

> `/review-spec 142`

**What happens:** pulls the live body, grounds findings in glossary / ADRs /
code, posts each finding as a **quoted comment**, sets `question`.

> *> "stay signed in for 30 days"*
> *What revokes a session early — password change, logout, admin? Not specified.*

**Output:** quoted findings on #142 + the `question` label. **Never approves.**

---

## Stage 5 — Respond  ·  `address-comments`  <span class="pill">author</span>

Works through the review **one comment at a time** — no batching.

> `/address-comments 142`

**What happens, per comment:**
- **accept** / **reject** / **modify** — settle one disposition with a rationale
- fold accepted edits into the **live issue body** (`gh issue edit`)
- post a **quoted reply** recording the outcome

Then clears `question` and `@`‑mentions reviewers to re‑run `/approve`.

<span class="small">Edits land on the issue, never the stale draft. Re‑pulls the body before editing.</span>

---

## Stage 6 — Approve  ·  `/approve`  <span class="pill">reviewer</span>

Approval is **comments‑only**. A reviewer comments:

> `/approve`

A **GitHub Action** (deferred — coming soon) verifies the reviewer is
authorized, counts approvals, and applies the **`approved`** label.

**No one sets `approved` by hand** — not a human, not a skill. That's what
makes it a trustworthy, forge‑proof gate.

> Anyone can check the gate, anytime:
> `/check-approval 142` → **APPROVED** *(or: needs‑approval, question)*

---

## Stage 6 — frozen means frozen

Once `approved` lands, the spec is **immutable**.

- The design body **cannot change** — the agent isn't building against a moving target.
- The issue **stays open** — it's the living record the tasks hang off.
- Need a change? Open a **new spec** that `supersedes: [142]`.

<span class="small">"Frozen" is about the *content*, not closing the issue.</span>

---

## Stage 7 — Slice  ·  `slice-to-subissues`  <span class="pill">author</span>

Breaks the approved spec into dependency‑ordered, **unit‑tested** `[Task]`
sub‑issues. **Gates on approval first** — refuses an unapproved spec.

> `/slice-to-subissues 142`

**What happens:** confirms `check-approval` says APPROVED, re‑pulls the spec,
proposes a task breakdown for you to confirm, then creates the sub‑issues in
dependency order and **backfills the spec's `tasks:`** frontmatter.

```
✓ #143 Data model      ✓ #145 Endpoints (blocked-by #143,#144)
✓ #144 Auth service    ✓ #146 Login form (blocked-by #145)
  #142 tasks: [143, 144, 145, 146]   ← backfilled
```

---

## Stage 7 — who owns the testing

> The **spec** owns the end‑to‑end contract — its **Acceptance Criteria**.
> Each **task** carries **unit tests only.**

A task is sized so one agent can pick it up and prove it in isolation.
No task re‑proves the whole login flow — that's the spec's job.

<span class="small">If a task seems to need its own e2e proof, the slice is probably too big.</span>

---

## Then: implementation

From here the agent builds against a frozen, approved contract:

`spec → tasks → PRs`, each task closed by its implementing PR.

A (deferred) **drift‑detection agent** will compare implementation against
the spec and flag divergence — so the code and the design don't drift into
two separate stories.

<span class="small">Implementation & drift detection are out of scope for this rollout — the workflow above is what we adopt now.</span>

---

## The rules that hold at every stage

- **The issue is canonical.** After `/post-spec`, always re‑pull from the
  issue before editing. Never trust a stale `.scratch/` draft.
- **Approval is comments‑only and Action‑set.** `/approve` is the signal; the
  `approved` label is applied only by the Action. No hand‑setting, no inferring
  from 👍.
- **Approved = frozen.** Immutable body; changes are new specs that `supersedes`
  the old one. Issue stays open.
- **`/post-spec` is the only human‑only step.** Everything else the agent can run
  — and skills can delegate to.

---

## Cheat sheet — keep this handy

| You want to… | Type |
|--------------|------|
| Not sure where you are | `/sdd` |
| Pin down a fuzzy design | `/grill-with-docs <intent>` |
| Write the spec | `/write-spec <intent>` |
| Publish the draft 🔒 | `/post-spec .scratch/<draft>.md` |
| Review someone's spec | `/review-spec <issue>` |
| See review comments | `/pull-comments <issue>` |
| Respond to review | `/address-comments <issue>` |
| Approve a spec | comment `/approve` on the issue |
| Is it approved? | `/check-approval <issue>` |
| Break it into tasks | `/slice-to-subissues <issue>` |

---

<!-- _class: lead -->

# That's the loop

**Draft → Post → Review → Address → Approve → Slice**

<br>

Design the thing. Get it approved. *Then* let the agent build.

<span class="small">Questions, or want to run a real one together? Grab me.</span>

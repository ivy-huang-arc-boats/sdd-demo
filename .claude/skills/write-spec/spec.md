```yaml
title: <short descriptive title>
authors: [<github-handle>]
approvers: [<github-handle>, <github-handle>]   # expected approvers, not proof
target-milestone: <e.g. Atlas Q3>
supersedes: []                                   # issue numbers of specs this replaces
tasks: []                                        # task issue numbers, backfilled after decomposition
```

<!--
  TEMPLATE — the parent design spec. Posted as a GitHub issue titled "[Spec] <title>".
  The GitHub issue is the source of truth once posted. The fenced `yaml` block above is
  machine-readable metadata — keep it a ```yaml fence (not a bare `---` frontmatter block,
  which GitHub renders as a giant heading inside an issue). `approvers` are the EXPECTED
  reviewers (not proof of approval — the `approved` label set by the Action is); `tasks` is
  backfilled by slice-to-subissues after decomposition.

  Fill every section. The required sections below exist to satisfy the 6 SDD
  requirements: enough context for an agent to build blind, a captured decision +
  rationale, rejected alternatives, an explicit out-of-scope, and a testable
  acceptance contract. Delete these HTML comments as you go.
-->

## Context
<!-- Background a reviewer needs. What exists today, why this is on the table now. -->

## Problem
<!-- The problem from the user's / system's perspective. What's broken or missing. -->

## Out of Scope
<!-- Explicit non-goals. What this spec deliberately does NOT cover. -->

## Solution
<!-- The chosen approach, from the user's perspective. The shape of what we're building. -->

## Key Design Choices
<!-- The decisions that define the design, each with a one-line rationale. -->

## Interfaces / Data Models / Constraints / Examples
<!--
  The concrete contract an agent builds against: interfaces, data models / schema,
  constraints, and worked examples. Concrete enough to implement without a follow-up
  conversation. Avoid hard file paths (they go stale); describe shapes and behavior.
-->

## Alternatives Considered
<!-- Each rejected alternative + WHY it was rejected. This is what makes the decision reviewable. -->

## Seams / Testing Decisions
<!--
  The single highest seam at which this feature is exercised end-to-end. Prefer an
  existing seam; if a new one is needed, propose it at the highest point. Describe
  what a good test looks like (external behavior, not implementation details).
  The spec owns the e2e contract; sub-issues only carry unit tests.
-->

## Acceptance Criteria
<!--
  The e2e contract, as a checklist. This is what the spec-level end-to-end test must
  prove. The feature is done when every box can be checked against a running system.
-->
- [ ] Criterion 1
- [ ] Criterion 2

## Milestones
<!-- High-level rollout steps and rough sequencing. -->

## Risks
<!-- Known risks and mitigations. -->

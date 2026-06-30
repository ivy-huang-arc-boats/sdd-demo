---
title: <short descriptive title>
spec-issue: <issue number>   # parent spec issue, filled at decomposition
blocked-by: []               # issue numbers that must land first
verified-by: unit            # tasks are unit-tested; the spec owns the e2e
---

<!--
  TEMPLATE — a vertical-slice sub-issue. Posted as a GitHub issue titled "[Task] <title>".
  Created by slice-to-subissues from an APPROVED spec. Each task is a unit of the spec's
  single behavior, unit-tested; the spec's Acceptance Criteria remain the e2e contract —
  a task does NOT re-prove the whole behavior end-to-end. Delete these comments as you go.
-->

## Parent
<!-- Back-link to the parent spec issue, e.g. "#<issue number>". -->

## What to build
<!--
  The end-to-end behavior of this slice, not a layer-by-layer implementation. Avoid hard
  file paths (they go stale). Describe what changes and how it behaves.
-->

## Acceptance criteria
<!-- Unit-level, checkable. What the unit tests for this task must prove. -->
- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by
<!-- References to blocking tasks, or "None — can start immediately". -->

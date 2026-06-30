# ADR 0001 — Sessions are opaque, server-side tokens

**Status:** Accepted · **Date:** 2026-05-12

## Context

Atlas needs to remember that a Member authenticated. Two broad options: a self-contained signed token (JWT)
the client carries, or an opaque token that's just a lookup key into server-side session state.

## Decision

Sessions are **opaque tokens** backed by a server-side `sessions` store. The token carries no claims; all
session state (owning Member, issued-at, expiry, revoked-at) lives server-side.

## Consequences

- **Revocation is real and immediate.** Deleting/expiring the server row signs the token out at once — no
  waiting for a JWT to expire. This is required for "sign out everywhere" and admin-forced logout.
- We pay a session-store read per authenticated request. Acceptable at Atlas's scale; revly cache later if
  it ever isn't.
- "Stay signed in" is just a longer expiry on the same mechanism — no second token type.

This ADR is the constraint any login/session spec must build within.

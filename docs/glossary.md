# Atlas glossary

The ubiquitous language for **Atlas**, Arc's internal ERP / MES / MRP platform. Specs and tasks use these
terms exactly. (This is a demo product — small on purpose, but the terms are used consistently so the worked
example reads like the real thing.)

- **Member** — a human who can sign in to Atlas. Identified by a unique email. Distinct from *Operator*
  (a shop-floor role) and *Account* (a billing entity) — a Member may hold many roles.
- **Credential** — the secret a Member authenticates with. Today: an email + a password hash. Stored apart
  from the Member's profile so auth concerns don't leak into the directory.
- **Session** — proof that a Member authenticated, carried as an opaque token. Has a lifetime; "stay signed
  in" extends it. Revoking a Session signs the Member out everywhere that token was used.
- **Directory** — the read model of Members (name, email, roles). Source of truth for *who exists*, not
  *how they prove it* — that's Credentials.
- **Seam** — the highest point at which a feature is exercised end-to-end. Atlas tests behavior at seams, not
  at internal layers. For HTTP features the seam is the request/response boundary.

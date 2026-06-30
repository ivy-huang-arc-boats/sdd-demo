// Directory — the read model of Members (who exists), per docs/glossary.md.
// Source of truth for identity, NOT for how a Member proves it (that's credentials).
//
// Demo skeleton: in-memory, just enough shape for a spec to reference.

/** @typedef {{ id: string, email: string, name: string, roles: string[] }} Member */

const byEmail = new Map();

/** @returns {Member | undefined} */
export function findByEmail(email) {
  return byEmail.get(email.toLowerCase());
}

/** @returns {Member} */
export function register({ email, name }) {
  const member = { id: crypto.randomUUID(), email: email.toLowerCase(), name, roles: [] };
  byEmail.set(member.email, member);
  return member;
}

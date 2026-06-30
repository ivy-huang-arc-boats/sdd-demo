// Credentials — the secret a Member authenticates with (email + password hash),
// stored apart from the Directory so auth concerns don't leak into identity.
//
// Demo skeleton: the verify/hash seam a login spec builds against. NOT a real
// implementation — hashing is stubbed.

/** @typedef {{ memberId: string, passwordHash: string }} Credential */

const byMemberId = new Map();

/** Stubbed — a real impl uses argon2id/bcrypt. */
function hash(password) {
  return `stub$${password.length}`;
}

export function setPassword(memberId, password) {
  byMemberId.set(memberId, { memberId, passwordHash: hash(password) });
}

/** @returns {boolean} */
export function verify(memberId, password) {
  const cred = byMemberId.get(memberId);
  return !!cred && cred.passwordHash === hash(password);
}

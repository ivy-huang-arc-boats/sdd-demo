// HTTP router — the request/response seam where Atlas features are exercised
// end-to-end (docs/glossary.md: "Seam"). Login/logout endpoints register here.
//
// Demo skeleton: a trivial method+path table, enough for a spec to name the seam.

const routes = [];

export function route(method, path, handler) {
  routes.push({ method, path, handler });
}

export function dispatch(req) {
  const match = routes.find((r) => r.method === req.method && r.path === req.path);
  if (!match) return { status: 404, body: { error: "not found" } };
  return match.handler(req);
}

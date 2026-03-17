/**
 * Extract user ID directly from the Bearer JWT payload.
 * Since verify_jwt = true in config.toml, Supabase gateway already
 * validates the signature before the function runs — we just decode.
 */
export function getUserId(req: Request): string | null {
  const auth = req.headers.get("Authorization");
  if (!auth?.startsWith("Bearer ")) return null;
  try {
    const payload = auth.split(" ")[1].split(".")[1];
    const decoded = JSON.parse(atob(payload));
    return decoded.sub ?? null;
  } catch {
    return null;
  }
}

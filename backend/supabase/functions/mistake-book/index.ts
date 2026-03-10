// ============================================================
// Edge Function: /mistake-book
// Handles: list mistakes, add note, resolve, review session
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url    = new URL(req.url);
  const method = req.method;
  const path   = url.pathname.replace(/^\/mistake-book\/?/, "");

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
  );

  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) return jsonError("Unauthorized", 401);

  try {
    // GET /mistake-book  ─── list all mistakes (unresolved by default)
    if (method === "GET" && path === "") {
      return await listMistakes(supabase, user.id, url);
    }

    // PATCH /mistake-book/:vocabId/note  ─── add/update personal note
    if (method === "PATCH" && path.endsWith("/note")) {
      const vocabId = path.replace("/note", "");
      const body = await req.json();
      return await updateNote(supabase, user.id, vocabId, body.note);
    }

    // PATCH /mistake-book/:vocabId/resolve  ─── mark resolved
    if (method === "PATCH" && path.endsWith("/resolve")) {
      const vocabId = path.replace("/resolve", "");
      return await resolveMistake(supabase, user.id, vocabId);
    }

    // GET /mistake-book/review-cards  ─── get a review batch of mistake-book cards
    if (method === "GET" && path === "review-cards") {
      return await getReviewCards(supabase, user.id, url);
    }

    // DELETE /mistake-book/:vocabId  ─── remove from mistake book
    if (method === "DELETE" && /^[0-9a-f-]{36}$/.test(path)) {
      return await removeMistake(supabase, user.id, path);
    }

    return jsonError("Not found", 404);
  } catch (err) {
    console.error(err);
    return jsonError("Internal server error", 500);
  }
});

// ─── Handlers ──────────────────────────────────────────────

async function listMistakes(supabase: any, userId: string, url: URL) {
  const resolved   = url.searchParams.get("resolved") === "true";
  const source     = url.searchParams.get("source");   // 'flashcard'|'article'|'grammar_exercise'
  const sortBy     = url.searchParams.get("sort") ?? "last_mistake_at";  // or 'mistake_count'
  const page       = parseInt(url.searchParams.get("page") ?? "1");
  const limit      = 30;

  let query = supabase
    .from("mistake_book")
    .select(`
      id, mistake_count, last_mistake_at, is_resolved, resolved_at,
      source_type, note, created_at,
      vocabulary:vocabulary_id (
        id, french_word, english_trans, word_class, gender,
        pronunciation_ipa, cefr_level, topic_tags, example_sentences, usage_notes
      )
    `, { count: "exact" })
    .eq("user_id", userId)
    .eq("is_resolved", resolved)
    .order(sortBy, { ascending: false })
    .range((page - 1) * limit, page * limit - 1);

  if (source) query = query.eq("source_type", source);

  const { data, error, count } = await query;
  if (error) return jsonError(error.message, 500);

  return jsonOk({ mistakes: data, total: count, page, limit, resolved });
}

async function updateNote(supabase: any, userId: string, vocabId: string, note: string) {
  const { data, error } = await supabase
    .from("mistake_book")
    .update({ note })
    .eq("user_id", userId)
    .eq("vocabulary_id", vocabId)
    .select()
    .single();

  if (error) return jsonError(error.message, 500);
  return jsonOk({ mistake: data });
}

async function resolveMistake(supabase: any, userId: string, vocabId: string) {
  const { data, error } = await supabase
    .from("mistake_book")
    .update({ is_resolved: true, resolved_at: new Date().toISOString() })
    .eq("user_id", userId)
    .eq("vocabulary_id", vocabId)
    .select()
    .single();

  if (error) return jsonError(error.message, 500);
  return jsonOk({ mistake: data });
}

async function getReviewCards(supabase: any, userId: string, url: URL) {
  const limit = parseInt(url.searchParams.get("limit") ?? "15");

  // Get unresolved mistakes ordered by most mistakes / most recent
  const { data, error } = await supabase
    .from("mistake_book")
    .select(`
      mistake_count, last_mistake_at, note,
      vocabulary:vocabulary_id (
        id, french_word, english_trans, translations, word_class, gender,
        pronunciation_ipa, audio_url, cefr_level, example_sentences, usage_notes
      )
    `)
    .eq("user_id", userId)
    .eq("is_resolved", false)
    .order("mistake_count", { ascending: false })
    .order("last_mistake_at", { ascending: false })
    .limit(limit);

  if (error) return jsonError(error.message, 500);

  return jsonOk({ cards: data ?? [], count: (data ?? []).length });
}

async function removeMistake(supabase: any, userId: string, vocabId: string) {
  const { error } = await supabase
    .from("mistake_book")
    .delete()
    .eq("user_id", userId)
    .eq("vocabulary_id", vocabId);

  if (error) return jsonError(error.message, 500);
  return jsonOk({ deleted: true });
}

// ─── Helpers ───────────────────────────────────────────────

function jsonOk(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status, headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
function jsonError(message: string, status: number) {
  return new Response(JSON.stringify({ error: message }), {
    status, headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

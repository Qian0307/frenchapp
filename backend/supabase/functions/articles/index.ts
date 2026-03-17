// ============================================================
// Edge Function: /articles
// Handles: daily article, article list, article detail, mark read
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { getUserId } from "../_shared/auth.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url    = new URL(req.url);
  const method = req.method;
  const path   = url.pathname.replace(/^\/articles\/?/, "");

  const userId = getUserId(req);
  if (!userId) return jsonError("Unauthorized", 401);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } } }
  );

  try {
    // GET /articles/daily  ─── today's article for the user's level
    if (method === "GET" && path === "daily") {
      return await getDailyArticle(supabase, userId);
    }

    // GET /articles/list  ─── paginated article browser
    if (method === "GET" && path === "list") {
      return await listArticles(supabase, userId, url);
    }

    // GET /articles/:id  ─── full article with annotated body
    if (method === "GET" && /^[0-9a-f-]{36}$/.test(path)) {
      return await getArticle(supabase, userId, path);
    }

    // POST /articles/:id/start  ─── mark reading started
    if (method === "POST" && path.endsWith("/start")) {
      const articleId = path.replace("/start", "");
      return await startRead(supabase, userId, articleId);
    }

    // PATCH /articles/:id/progress  ─── update reading progress
    if (method === "PATCH" && path.endsWith("/progress")) {
      const articleId = path.replace("/progress", "");
      const body = await req.json();
      return await updateProgress(supabase, userId, articleId, body);
    }

    // POST /articles/:id/vocabulary/:vocabId/lookup  ─── tap on word
    if (method === "POST" && path.includes("/vocabulary/")) {
      const [articleId, , vocabId] = path.split("/");
      return await lookupVocab(supabase, userId, articleId, vocabId);
    }

    return jsonError("Not found", 404);
  } catch (err) {
    console.error(err);
    return jsonError("Internal server error", 500);
  }
});

// ─── Handlers ──────────────────────────────────────────────

async function getDailyArticle(supabase: any, userId: string) {
  // Get user's current level
  const { data: profile } = await supabase
    .from("profiles")
    .select("current_level")
    .eq("id", userId)
    .single();

  const today = new Date().toISOString().split("T")[0];

  const { data, error } = await supabase
    .from("daily_articles")
    .select(`
      article_id,
      article:article_id (
        id, title, subtitle, cover_image_url, cefr_level,
        topic_tags, word_count, reading_time_mins, published_date, author
      )
    `)
    .eq("schedule_date", today)
    .eq("cefr_level", profile?.current_level ?? "A1")
    .single();

  if (error || !data) {
    // Fallback: latest published article for user's level
    const { data: fallback, error: fbErr } = await supabase
      .from("articles")
      .select("id, title, subtitle, cover_image_url, cefr_level, topic_tags, word_count, reading_time_mins, published_date, author")
      .eq("is_published", true)
      .eq("cefr_level", profile?.current_level ?? "A1")
      .order("published_date", { ascending: false })
      .limit(1)
      .single();

    if (fbErr) return jsonError("No daily article available", 404);
    return jsonOk({ article: fallback, is_fallback: true });
  }

  // Check if user already read it
  const { data: readRecord } = await supabase
    .from("user_article_reads")
    .select("progress_pct, is_completed")
    .eq("user_id", userId)
    .eq("article_id", data.article_id)
    .single();

  return jsonOk({
    article: data.article,
    read_progress: readRecord ?? null,
    is_fallback: false,
  });
}

async function listArticles(supabase: any, userId: string, url: URL) {
  const level    = url.searchParams.get("level");
  const tag      = url.searchParams.get("tag");
  const page     = parseInt(url.searchParams.get("page") ?? "1");
  const limit    = 20;

  let query = supabase
    .from("articles")
    .select(
      "id, title, subtitle, cover_image_url, cefr_level, topic_tags, word_count, reading_time_mins, published_date, author",
      { count: "exact" }
    )
    .eq("is_published", true)
    .order("published_date", { ascending: false })
    .range((page - 1) * limit, page * limit - 1);

  if (level) query = query.eq("cefr_level", level);
  if (tag)   query = query.contains("topic_tags", [tag]);

  const { data: articles, error, count } = await query;
  if (error) return jsonError(error.message, 500);

  // Fetch read status for this user
  const articleIds = (articles ?? []).map((a: any) => a.id);
  const { data: reads } = await supabase
    .from("user_article_reads")
    .select("article_id, progress_pct, is_completed")
    .eq("user_id", userId)
    .in("article_id", articleIds);

  const readMap = Object.fromEntries(
    (reads ?? []).map((r: any) => [r.article_id, r])
  );

  const enriched = (articles ?? []).map((a: any) => ({
    ...a,
    read_progress: readMap[a.id] ?? null,
  }));

  return jsonOk({ articles: enriched, total: count, page, limit });
}

async function getArticle(supabase: any, userId: string, articleId: string) {
  const { data, error } = await supabase
    .from("articles")
    .select("*")
    .eq("id", articleId)
    .eq("is_published", true)
    .single();

  if (error || !data) return jsonError("Article not found", 404);

  // Get linked vocabulary (pre-fetch for overlay display)
  const { data: vocab } = await supabase
    .from("article_vocabulary")
    .select(`
      vocabulary_id, occurrences,
      vocabulary:vocabulary_id (
        id, french_word, english_trans, word_class, gender,
        pronunciation_ipa, cefr_level, example_sentences, usage_notes
      )
    `)
    .eq("article_id", articleId);

  // Get user's read record
  const { data: readRecord } = await supabase
    .from("user_article_reads")
    .select("*")
    .eq("user_id", userId)
    .eq("article_id", articleId)
    .single();

  return jsonOk({
    article: data,
    linked_vocabulary: vocab ?? [],
    read_progress: readRecord ?? null,
  });
}

async function startRead(supabase: any, userId: string, articleId: string) {
  const { data, error } = await supabase
    .from("user_article_reads")
    .upsert(
      { user_id: userId, article_id: articleId, started_at: new Date().toISOString() },
      { onConflict: "user_id,article_id", ignoreDuplicates: true }
    )
    .select()
    .single();

  if (error) return jsonError(error.message, 500);
  return jsonOk({ read: data });
}

async function updateProgress(supabase: any, userId: string, articleId: string, body: any) {
  const { progress_pct, words_looked_up, time_spent_secs } = body;
  const is_completed = progress_pct >= 95;

  const update: any = { progress_pct, time_spent_secs };
  if (words_looked_up !== undefined) update.words_looked_up = words_looked_up;
  if (is_completed) {
    update.is_completed  = true;
    update.completed_at  = new Date().toISOString();
  }

  const { data, error } = await supabase
    .from("user_article_reads")
    .update(update)
    .eq("user_id", userId)
    .eq("article_id", articleId)
    .select()
    .single();

  if (error) return jsonError(error.message, 500);

  // Award XP for completion
  if (is_completed) {
    await supabase.rpc("award_xp", { p_user_id: userId, p_xp: 20 });
  }

  return jsonOk({ read: data });
}

async function lookupVocab(
  supabase: any, userId: string, articleId: string, vocabId: string
) {
  // Auto-enroll the looked-up word
  await supabase
    .from("user_vocabulary_progress")
    .upsert(
      { user_id: userId, vocabulary_id: vocabId },
      { onConflict: "user_id,vocabulary_id", ignoreDuplicates: true }
    );

  // Fetch full word detail
  const { data, error } = await supabase
    .from("vocabulary")
    .select("*")
    .eq("id", vocabId)
    .single();

  if (error || !data) return jsonError("Vocabulary not found", 404);

  // Increment words_looked_up
  await supabase.rpc("increment_article_words_looked_up", {
    p_user_id:   userId,
    p_article_id: articleId,
  });

  return jsonOk({ vocabulary: data });
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

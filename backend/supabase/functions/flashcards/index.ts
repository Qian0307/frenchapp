// ============================================================
// Edge Function: /flashcards
// Handles: get due cards, submit review, get card detail
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { sm2, SM2Result } from "../_shared/sm2.ts";
import { corsHeaders } from "../_shared/cors.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url    = new URL(req.url);
  const method = req.method;
  const path   = url.pathname.replace(/^\/flashcards\/?/, "");

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
  );

  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) {
    return jsonError("Unauthorized", 401);
  }

  try {
    // GET /flashcards/due  ─── return today's due cards
    if (method === "GET" && path === "due") {
      return await getDueCards(supabase, user.id, url);
    }

    // GET /flashcards/browse ─── browse vocabulary by level / tag
    if (method === "GET" && path === "browse") {
      return await browseVocabulary(supabase, url);
    }

    // POST /flashcards/start ─── open a new review session
    if (method === "POST" && path === "start") {
      return await startSession(supabase, user.id);
    }

    // POST /flashcards/review ─── submit an individual card review
    if (method === "POST" && path === "review") {
      const body = await req.json();
      return await submitReview(supabase, user.id, body);
    }

    // POST /flashcards/end ─── close a review session
    if (method === "POST" && path === "end") {
      const body = await req.json();
      return await endSession(supabase, user.id, body);
    }

    // POST /flashcards/enroll ─── add a vocabulary card to user's deck
    if (method === "POST" && path === "enroll") {
      const body = await req.json();
      return await enrollCard(supabase, user.id, body.vocabulary_id);
    }

    return jsonError("Not found", 404);
  } catch (err) {
    console.error(err);
    return jsonError("Internal server error", 500);
  }
});

// ─── Handlers ──────────────────────────────────────────────

async function getDueCards(supabase: any, userId: string, url: URL) {
  const limit = parseInt(url.searchParams.get("limit") ?? "20");
  const type  = url.searchParams.get("type") ?? "scheduled"; // scheduled | new | starred

  let query = supabase
    .from("user_vocabulary_progress")
    .select(`
      id, repetitions, ease_factor, interval_days, due_date,
      total_reviews, correct_reviews, is_learned, is_starred,
      vocabulary:vocabulary_id (
        id, french_word, english_trans, translations, word_class, gender,
        plural_form, conjugations, pronunciation_ipa, audio_url, cefr_level,
        topic_tags, example_sentences, usage_notes, memory_tip
      )
    `)
    .eq("user_id", userId)
    .limit(limit);

  if (type === "scheduled") {
    query = query.lte("due_date", new Date().toISOString().split("T")[0]);
  } else if (type === "new") {
    query = query.eq("repetitions", 0);
  } else if (type === "starred") {
    query = query.eq("is_starred", true);
  }

  const { data, error } = await query;
  if (error) return jsonError(error.message, 500);

  // Shuffle to avoid predictable ordering
  const shuffled = (data ?? []).sort(() => Math.random() - 0.5);

  return jsonOk({ cards: shuffled, count: shuffled.length });
}

async function browseVocabulary(supabase: any, url: URL) {
  const level  = url.searchParams.get("level");
  const tag    = url.searchParams.get("tag");
  const search = url.searchParams.get("q");
  const page   = parseInt(url.searchParams.get("page") ?? "1");
  const limit  = 30;

  let query = supabase
    .from("vocabulary")
    .select("id, french_word, english_trans, word_class, gender, cefr_level, topic_tags, pronunciation_ipa", { count: "exact" })
    .eq("is_active", true)
    .order("frequency_rank", { ascending: true, nullsFirst: false })
    .range((page - 1) * limit, page * limit - 1);

  if (level) query = query.eq("cefr_level", level);
  if (tag)   query = query.contains("topic_tags", [tag]);
  if (search) query = query.or(`french_word.ilike.%${search}%,english_trans.ilike.%${search}%`);

  const { data, error, count } = await query;
  if (error) return jsonError(error.message, 500);

  return jsonOk({ vocabulary: data, total: count, page, limit });
}

async function startSession(supabase: any, userId: string) {
  const { data, error } = await supabase
    .from("review_sessions")
    .insert({ user_id: userId, session_type: "scheduled" })
    .select()
    .single();

  if (error) return jsonError(error.message, 500);
  return jsonOk({ session: data });
}

async function submitReview(supabase: any, userId: string, body: any) {
  const { session_id, vocabulary_id, quality, response_ms } = body;

  if (!session_id || !vocabulary_id || !quality) {
    return jsonError("session_id, vocabulary_id and quality are required", 400);
  }

  // Fetch current SM-2 state
  const { data: prog, error: progErr } = await supabase
    .from("user_vocabulary_progress")
    .select("repetitions, ease_factor, interval_days")
    .eq("user_id", userId)
    .eq("vocabulary_id", vocabulary_id)
    .single();

  if (progErr) return jsonError("Card not found in user deck", 404);

  // Map quality string to numeric grade
  const gradeMap: Record<string, number> = { again: 0, hard: 1, good: 2, easy: 3 };
  const grade = gradeMap[quality] ?? 2;

  const result: SM2Result = sm2(
    { repetitions: prog.repetitions, easeFactor: prog.ease_factor, intervalDays: prog.interval_days },
    grade
  );

  const today = new Date();
  const dueDate = new Date(today);
  dueDate.setDate(today.getDate() + result.intervalDays);

  // Update progress row
  const { error: updateErr } = await supabase
    .from("user_vocabulary_progress")
    .update({
      repetitions:     result.repetitions,
      ease_factor:     result.easeFactor,
      interval_days:   result.intervalDays,
      due_date:        dueDate.toISOString().split("T")[0],
      total_reviews:   prog.total_reviews + 1,
      correct_reviews: prog.correct_reviews + (grade >= 2 ? 1 : 0),
      last_reviewed:   new Date().toISOString(),
      is_learned:      result.repetitions >= 3 && grade >= 2,
    })
    .eq("user_id", userId)
    .eq("vocabulary_id", vocabulary_id);

  if (updateErr) return jsonError(updateErr.message, 500);

  // Insert review event
  await supabase.from("review_events").insert({
    session_id,
    user_id:         userId,
    vocabulary_id,
    quality,
    response_ms,
    new_interval:    result.intervalDays,
    new_ease_factor: result.easeFactor,
    new_repetitions: result.repetitions,
  });

  // Add to mistake book if again/hard
  if (grade <= 1) {
    await supabase.from("mistake_book").upsert({
      user_id:      userId,
      vocabulary_id,
      source_type:  "flashcard",
      source_id:    session_id,
      is_resolved:  false,
      last_mistake_at: new Date().toISOString(),
    }, {
      onConflict: "user_id,vocabulary_id",
      ignoreDuplicates: false,
    });

    // increment mistake_count via RPC
    await supabase.rpc("increment_mistake_count", { p_user_id: userId, p_vocab_id: vocabulary_id });
  }

  // Update streak
  await supabase.rpc("update_streak", { p_user_id: userId });

  return jsonOk({ result, due_date: dueDate.toISOString().split("T")[0] });
}

async function endSession(supabase: any, userId: string, body: any) {
  const { session_id, cards_reviewed, cards_correct, duration_secs } = body;

  const { data, error } = await supabase
    .from("review_sessions")
    .update({
      ended_at:       new Date().toISOString(),
      cards_reviewed,
      cards_correct,
      duration_secs,
    })
    .eq("id", session_id)
    .eq("user_id", userId)
    .select()
    .single();

  if (error) return jsonError(error.message, 500);

  // Award XP: 2 per correct card, 1 per reviewed
  const xp = cards_correct * 2 + (cards_reviewed - cards_correct) * 1;
  await supabase.rpc("award_xp", { p_user_id: userId, p_xp: xp });

  return jsonOk({ session: data, xp_earned: xp });
}

async function enrollCard(supabase: any, userId: string, vocabularyId: string) {
  const { data, error } = await supabase
    .from("user_vocabulary_progress")
    .insert({ user_id: userId, vocabulary_id: vocabularyId })
    .select()
    .single();

  if (error?.code === "23505") {
    return jsonError("Card already enrolled", 409);
  }
  if (error) return jsonError(error.message, 500);

  return jsonOk({ progress: data });
}

// ─── Helpers ───────────────────────────────────────────────

function jsonOk(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function jsonError(message: string, status: number) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

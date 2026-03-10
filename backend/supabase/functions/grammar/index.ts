// ============================================================
// Edge Function: /grammar
// Handles: lesson list, lesson detail, submit exercise attempt
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
  const path   = url.pathname.replace(/^\/grammar\/?/, "");

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
  );

  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) return jsonError("Unauthorized", 401);

  try {
    // GET /grammar/lessons  ─── list lessons with progress
    if (method === "GET" && path === "lessons") {
      return await listLessons(supabase, user.id, url);
    }

    // GET /grammar/lessons/:id  ─── lesson detail + exercises
    if (method === "GET" && path.startsWith("lessons/")) {
      const lessonId = path.replace("lessons/", "");
      return await getLesson(supabase, user.id, lessonId);
    }

    // POST /grammar/exercises/:id/attempt  ─── submit answer
    if (method === "POST" && path.startsWith("exercises/") && path.endsWith("/attempt")) {
      const exerciseId = path.replace("exercises/", "").replace("/attempt", "");
      const body = await req.json();
      return await submitAttempt(supabase, user.id, exerciseId, body);
    }

    // POST /grammar/lessons/:id/complete  ─── mark lesson complete
    if (method === "POST" && path.startsWith("lessons/") && path.endsWith("/complete")) {
      const lessonId = path.replace("lessons/", "").replace("/complete", "");
      const body = await req.json();
      return await completeLesson(supabase, user.id, lessonId, body);
    }

    return jsonError("Not found", 404);
  } catch (err) {
    console.error(err);
    return jsonError("Internal server error", 500);
  }
});

// ─── Handlers ──────────────────────────────────────────────

async function listLessons(supabase: any, userId: string, url: URL) {
  const level = url.searchParams.get("level");

  let query = supabase
    .from("grammar_lessons")
    .select("id, title, slug, description, cefr_level, topic_category, sort_order, tips")
    .eq("is_published", true)
    .order("cefr_level")
    .order("sort_order");

  if (level) query = query.eq("cefr_level", level);

  const { data: lessons, error } = await query;
  if (error) return jsonError(error.message, 500);

  // Fetch user progress for all lessons
  const { data: progress } = await supabase
    .from("user_grammar_progress")
    .select("lesson_id, is_started, is_completed, best_score_pct")
    .eq("user_id", userId);

  const progressMap = Object.fromEntries(
    (progress ?? []).map((p: any) => [p.lesson_id, p])
  );

  const enriched = (lessons ?? []).map((l: any) => ({
    ...l,
    progress: progressMap[l.id] ?? null,
  }));

  return jsonOk({ lessons: enriched });
}

async function getLesson(supabase: any, userId: string, lessonId: string) {
  const { data: lesson, error } = await supabase
    .from("grammar_lessons")
    .select("*")
    .eq("id", lessonId)
    .eq("is_published", true)
    .single();

  if (error || !lesson) return jsonError("Lesson not found", 404);

  const { data: exercises, error: exErr } = await supabase
    .from("grammar_exercises")
    .select("id, exercise_type, sort_order, prompt, prompt_audio_url, options, hint, xp_reward")
    .eq("lesson_id", lessonId)
    .order("sort_order");

  if (exErr) return jsonError(exErr.message, 500);

  // Fetch user progress for this lesson
  const { data: progress } = await supabase
    .from("user_grammar_progress")
    .select("*")
    .eq("user_id", userId)
    .eq("lesson_id", lessonId)
    .single();

  // Mark as started
  if (!progress?.is_started) {
    await supabase.from("user_grammar_progress").upsert({
      user_id:    userId,
      lesson_id:  lessonId,
      is_started: true,
    }, { onConflict: "user_id,lesson_id" });
  }

  return jsonOk({
    lesson,
    exercises: exercises ?? [],
    progress:  progress ?? null,
  });
}

async function submitAttempt(
  supabase: any, userId: string, exerciseId: string, body: any
) {
  const { user_answer, response_ms } = body;

  // Fetch correct answer
  const { data: exercise, error } = await supabase
    .from("grammar_exercises")
    .select("id, lesson_id, exercise_type, correct_answer, explanation, xp_reward")
    .eq("id", exerciseId)
    .single();

  if (error || !exercise) return jsonError("Exercise not found", 404);

  const is_correct = checkAnswer(exercise.exercise_type, user_answer, exercise.correct_answer);

  // Record attempt
  await supabase.from("user_exercise_attempts").insert({
    user_id:     userId,
    exercise_id: exerciseId,
    lesson_id:   exercise.lesson_id,
    user_answer,
    is_correct,
    response_ms,
  });

  // Add to mistake book if wrong
  // (For grammar, we'd link a vocabulary if the exercise involves one)

  if (is_correct) {
    await supabase.rpc("award_xp", { p_user_id: userId, p_xp: exercise.xp_reward });
  }

  return jsonOk({
    is_correct,
    correct_answer: exercise.correct_answer,
    explanation:    exercise.explanation,
    xp_earned:      is_correct ? exercise.xp_reward : 0,
  });
}

async function completeLesson(
  supabase: any, userId: string, lessonId: string, body: any
) {
  const { score_pct } = body;

  const { data, error } = await supabase
    .from("user_grammar_progress")
    .upsert({
      user_id:         userId,
      lesson_id:       lessonId,
      is_started:      true,
      is_completed:    score_pct >= 60,
      best_score_pct:  score_pct,
      attempts:        1,
      last_attempt_at: new Date().toISOString(),
      completed_at:    score_pct >= 60 ? new Date().toISOString() : null,
    }, {
      onConflict: "user_id,lesson_id",
      ignoreDuplicates: false,
    })
    .select()
    .single();

  if (error) return jsonError(error.message, 500);

  // Recalculate user level
  await supabase.rpc("recalculate_user_level", { p_user_id: userId });

  return jsonOk({ progress: data });
}

// ─── Answer Checker ────────────────────────────────────────

function checkAnswer(type: string, userAnswer: unknown, correctAnswer: unknown): boolean {
  const correct = typeof correctAnswer === "string"
    ? JSON.parse(correctAnswer as string)
    : correctAnswer;

  const user = typeof userAnswer === "string"
    ? userAnswer.trim().toLowerCase()
    : userAnswer;

  switch (type) {
    case "multiple_choice":
      return String(user) === String(correct);

    case "fill_blank":
      if (typeof user === "string" && typeof correct === "string") {
        return normalise(user) === normalise(correct);
      }
      if (Array.isArray(user) && Array.isArray(correct)) {
        return user.every((u, i) => normalise(String(u)) === normalise(String(correct[i])));
      }
      return false;

    case "translation":
      // Simple normalised comparison; real implementation would use NLP or LLM check
      return normalise(String(user)) === normalise(String(correct));

    case "reorder":
      if (!Array.isArray(user) || !Array.isArray(correct)) return false;
      return JSON.stringify(user.map(String)) === JSON.stringify(correct.map(String));

    case "matching":
      if (typeof user !== "object" || typeof correct !== "object") return false;
      return JSON.stringify(user) === JSON.stringify(correct);

    default:
      return false;
  }
}

function normalise(s: string): string {
  return s
    .toLowerCase()
    .trim()
    .replace(/['']/g, "'")        // smart quotes → straight
    .replace(/\s+/g, " ");
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

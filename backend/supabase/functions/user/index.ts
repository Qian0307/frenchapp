// ============================================================
// Edge Function: /user
// Handles: GET /user/stats  — dashboard statistics
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { getUserId } from "../_shared/auth.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url  = new URL(req.url);
  const path = url.pathname.replace(/^\/user\/?/, "");

  const userId = getUserId(req);
  if (!userId) return jsonError("Unauthorized", 401);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } } }
  );

  try {
    if (req.method === "GET" && path === "stats") {
      return await getStats(supabase, userId);
    }
    return jsonError("Not found", 404);
  } catch (err) {
    console.error(err);
    return jsonError("Internal server error", 500);
  }
});

async function getStats(supabase: any, userId: string) {
  const today = new Date().toISOString().split("T")[0];

  const { data: profile } = await supabase
    .from("profiles")
    .select("streak_days, total_xp, current_level, daily_goal_cards")
    .eq("id", userId)
    .single();

  const { count: cardsDue } = await supabase
    .from("user_vocabulary_progress")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
    .lte("due_date", today);

  const { count: cardsToday } = await supabase
    .from("review_events")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
    .gte("created_at", `${today}T00:00:00.000Z`);

  const { data: todaySessions } = await supabase
    .from("review_sessions")
    .select("cards_correct, cards_reviewed")
    .eq("user_id", userId)
    .gte("ended_at", `${today}T00:00:00.000Z`)
    .not("ended_at", "is", null);

  const xpToday = (todaySessions ?? []).reduce(
    (sum: number, s: any) =>
      sum + (s.cards_correct ?? 0) * 2 + ((s.cards_reviewed ?? 0) - (s.cards_correct ?? 0)),
    0
  );

  return jsonOk({
    streak_days:   profile?.streak_days   ?? 0,
    cards_due:     cardsDue               ?? 0,
    cards_today:   cardsToday             ?? 0,
    xp_today:      xpToday,
    current_level: profile?.current_level ?? "A1",
  });
}

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

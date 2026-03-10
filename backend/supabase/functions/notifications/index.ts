// ============================================================
// Edge Function: /notifications
// Called by a pg_cron job every hour to dispatch push notifications
// Also handles token registration and preference updates
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

// Expo Push Notification service endpoint
const EXPO_PUSH_URL = "https://exp.host/--/api/v2/push/send";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url    = new URL(req.url);
  const method = req.method;
  const path   = url.pathname.replace(/^\/notifications\/?/, "");

  // Service-role client for scheduler (no user auth)
  const serviceSupabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // Anon client for user-authenticated routes
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
  );

  try {
    // POST /notifications/dispatch  ─── cron job trigger (service role)
    if (method === "POST" && path === "dispatch") {
      const secret = req.headers.get("x-cron-secret");
      if (secret !== Deno.env.get("CRON_SECRET")) {
        return jsonError("Forbidden", 403);
      }
      return await dispatchScheduledNotifications(serviceSupabase);
    }

    // Require user auth for the rest
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) return jsonError("Unauthorized", 401);

    // POST /notifications/token  ─── register push token
    if (method === "POST" && path === "token") {
      const body = await req.json();
      return await registerToken(supabase, user.id, body);
    }

    // DELETE /notifications/token  ─── unregister push token
    if (method === "DELETE" && path === "token") {
      const body = await req.json();
      return await deregisterToken(supabase, user.id, body.token);
    }

    // GET /notifications/preferences  ─── get user preferences
    if (method === "GET" && path === "preferences") {
      return await getPreferences(supabase, user.id);
    }

    // PUT /notifications/preferences  ─── update user preferences
    if (method === "PUT" && path === "preferences") {
      const body = await req.json();
      return await updatePreferences(supabase, user.id, body);
    }

    // GET /notifications/history  ─── past notifications
    if (method === "GET" && path === "history") {
      return await getHistory(supabase, user.id);
    }

    // PATCH /notifications/:id/open  ─── mark opened
    if (method === "PATCH" && path.endsWith("/open")) {
      const notifId = path.replace("/open", "");
      return await markOpened(supabase, user.id, notifId);
    }

    return jsonError("Not found", 404);
  } catch (err) {
    console.error(err);
    return jsonError("Internal server error", 500);
  }
});

// ─── Scheduler ─────────────────────────────────────────────

async function dispatchScheduledNotifications(supabase: any) {
  const currentHourUTC = new Date().getUTCHours();
  const results = { sent: 0, failed: 0 };

  // Get users whose local notification_hour matches current UTC hour
  // (simplified: assumes notification_hour is in UTC; real app would use timezone offset)
  const { data: users } = await supabase
    .from("v_daily_review_due")
    .select("user_id, cards_due, streak_days")
    .eq("notification_hour", currentHourUTC)
    .gt("cards_due", 0);

  for (const u of users ?? []) {
    const tokens = await getUserTokens(supabase, u.user_id);
    if (!tokens.length) continue;

    const message = buildReviewMessage(u.cards_due, u.streak_days);
    const success = await sendPushBatch(tokens, message, supabase, u.user_id);
    success ? results.sent++ : results.failed++;
  }

  // Daily article notifications
  const { data: articleUsers } = await supabase
    .from("profiles")
    .select("id, notification_hour")
    .eq("notification_hour", currentHourUTC);

  for (const u of articleUsers ?? []) {
    const tokens = await getUserTokens(supabase, u.id);
    if (!tokens.length) continue;
    await sendPushBatch(tokens, {
      title: "Lecture du jour",
      body:  "Votre article quotidien est disponible. Bonne lecture !",
      data:  { type: "daily_article" },
    }, supabase, u.id);
  }

  return jsonOk({ results });
}

async function getUserTokens(supabase: any, userId: string): Promise<string[]> {
  const { data } = await supabase
    .from("push_tokens")
    .select("token")
    .eq("user_id", userId)
    .eq("is_active", true);
  return (data ?? []).map((r: any) => r.token);
}

function buildReviewMessage(cardsDue: number, streakDays: number) {
  return {
    title: `${cardsDue} carte${cardsDue > 1 ? "s" : ""} à réviser`,
    body:  streakDays > 0
      ? `Série de ${streakDays} jour${streakDays > 1 ? "s" : ""} — continuez !`
      : "Révisez vos flashcards pour progresser.",
    data: { type: "review_due", cards_due: cardsDue },
  };
}

async function sendPushBatch(
  tokens: string[],
  message: { title: string; body: string; data?: object },
  supabase: any,
  userId: string
): Promise<boolean> {
  const messages = tokens.map((token) => ({
    to:    token,
    sound: "default",
    title: message.title,
    body:  message.body,
    data:  message.data ?? {},
  }));

  try {
    const res = await fetch(EXPO_PUSH_URL, {
      method:  "POST",
      headers: { "Content-Type": "application/json" },
      body:    JSON.stringify(messages),
    });

    if (!res.ok) return false;

    // Log in DB
    await supabase.from("notification_log").insert({
      user_id:           userId,
      notification_type: (message.data as any)?.type ?? "review_due",
      title:             message.title,
      body:              message.body,
      payload:           message.data,
    });

    return true;
  } catch {
    return false;
  }
}

// ─── User-facing handlers ──────────────────────────────────

async function registerToken(supabase: any, userId: string, body: any) {
  const { token, platform } = body;
  if (!token || !platform) return jsonError("token and platform required", 400);

  const { data, error } = await supabase
    .from("push_tokens")
    .upsert({ user_id: userId, token, platform, is_active: true },
             { onConflict: "user_id,token" })
    .select()
    .single();

  if (error) return jsonError(error.message, 500);
  return jsonOk({ token: data });
}

async function deregisterToken(supabase: any, userId: string, token: string) {
  await supabase
    .from("push_tokens")
    .update({ is_active: false })
    .eq("user_id", userId)
    .eq("token", token);
  return jsonOk({ deregistered: true });
}

async function getPreferences(supabase: any, userId: string) {
  const { data } = await supabase
    .from("notification_preferences")
    .select("*")
    .eq("user_id", userId)
    .single();
  return jsonOk({ preferences: data });
}

async function updatePreferences(supabase: any, userId: string, body: any) {
  const { data, error } = await supabase
    .from("notification_preferences")
    .upsert({ user_id: userId, ...body }, { onConflict: "user_id" })
    .select()
    .single();
  if (error) return jsonError(error.message, 500);
  return jsonOk({ preferences: data });
}

async function getHistory(supabase: any, userId: string) {
  const { data } = await supabase
    .from("notification_log")
    .select("*")
    .eq("user_id", userId)
    .order("sent_at", { ascending: false })
    .limit(50);
  return jsonOk({ notifications: data ?? [] });
}

async function markOpened(supabase: any, userId: string, notifId: string) {
  await supabase
    .from("notification_log")
    .update({ is_opened: true, opened_at: new Date().toISOString() })
    .eq("id", notifId)
    .eq("user_id", userId);
  return jsonOk({ opened: true });
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

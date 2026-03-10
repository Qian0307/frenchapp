-- ============================================================
-- French Learning App  ·  pg_cron Scheduled Jobs
-- Run once after deploying Edge Functions
-- ============================================================

-- Enable pg_cron (Supabase: toggle in Dashboard → Database → Extensions)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- ── 1. Dispatch review + article notifications every hour ────

SELECT cron.schedule(
  'dispatch-notifications-hourly',
  '0 * * * *',               -- every hour on the hour
  $$
    SELECT net.http_post(
      url := current_setting('app.edge_function_base_url') || '/notifications/dispatch',
      headers := jsonb_build_object(
        'Content-Type',    'application/json',
        'x-cron-secret',  current_setting('app.cron_secret')
      ),
      body := '{}'::jsonb
    );
  $$
);

-- ── 2. Schedule daily articles (runs at 00:05 UTC every day) ─

SELECT cron.schedule(
  'schedule-daily-articles',
  '5 0 * * *',
  $$
  INSERT INTO daily_articles (schedule_date, cefr_level, article_id)
  SELECT
    CURRENT_DATE + 1,
    a.cefr_level,
    a.id
  FROM articles a
  WHERE a.is_published = true
    AND a.id NOT IN (
      SELECT article_id FROM daily_articles
      WHERE schedule_date >= CURRENT_DATE - 30  -- avoid recent repeats
    )
  ORDER BY
    a.cefr_level,
    RANDOM()                -- random selection per level
  LIMIT 6                  -- one per CEFR level
  ON CONFLICT (schedule_date, cefr_level) DO NOTHING;
  $$
);

-- ── 3. Expire inactive push tokens (runs weekly Sunday 03:00) ─

SELECT cron.schedule(
  'expire-inactive-tokens',
  '0 3 * * 0',
  $$
  UPDATE push_tokens
  SET is_active = false
  WHERE updated_at < NOW() - INTERVAL '90 days'
    AND is_active = true;
  $$
);

-- ── 4. Award streak-break detection (daily 01:00 UTC) ─────────

SELECT cron.schedule(
  'break-streaks',
  '0 1 * * *',
  $$
  UPDATE profiles
  SET streak_days = 0
  WHERE last_study_date < CURRENT_DATE - 1
    AND streak_days > 0;
  $$
);

-- ── Helper RPC used by Edge Functions ─────────────────────────

CREATE OR REPLACE FUNCTION increment_mistake_count(p_user_id uuid, p_vocab_id uuid)
RETURNS void LANGUAGE sql SECURITY DEFINER AS $$
  UPDATE mistake_book
  SET mistake_count = mistake_count + 1,
      last_mistake_at = now()
  WHERE user_id = p_user_id AND vocabulary_id = p_vocab_id;
$$;

CREATE OR REPLACE FUNCTION increment_article_words_looked_up(p_user_id uuid, p_article_id uuid)
RETURNS void LANGUAGE sql SECURITY DEFINER AS $$
  UPDATE user_article_reads
  SET words_looked_up = words_looked_up + 1
  WHERE user_id = p_user_id AND article_id = p_article_id;
$$;

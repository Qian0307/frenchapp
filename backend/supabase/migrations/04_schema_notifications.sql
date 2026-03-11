-- ============================================================
-- French Learning App  ·  Database Schema  ·  Part 4: Notifications
-- ============================================================

-- ============================================================
-- PUSH NOTIFICATION TOKENS
-- ============================================================

CREATE TABLE push_tokens (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  token       text NOT NULL,
  platform    text NOT NULL CHECK (platform IN ('ios','android')),
  is_active   boolean NOT NULL DEFAULT true,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, token)
);

CREATE INDEX idx_push_tokens_user ON push_tokens(user_id) WHERE is_active;

ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "push_tokens_self" ON push_tokens
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- ============================================================
-- NOTIFICATION LOG
-- ============================================================

CREATE TABLE notification_log (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  notification_type notification_type NOT NULL,
  title             text NOT NULL,
  body              text NOT NULL,
  payload           jsonb,          -- deep link data
  sent_at           timestamptz NOT NULL DEFAULT now(),
  opened_at         timestamptz,
  is_opened         boolean NOT NULL DEFAULT false
);

CREATE INDEX idx_notif_log_user ON notification_log(user_id, sent_at DESC);

ALTER TABLE notification_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "notif_log_self" ON notification_log
  USING (user_id = auth.uid());

-- ============================================================
-- USER NOTIFICATION PREFERENCES
-- ============================================================

CREATE TABLE notification_preferences (
  user_id               uuid PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  review_due_enabled    boolean NOT NULL DEFAULT true,
  daily_article_enabled boolean NOT NULL DEFAULT true,
  streak_reminder_enabled boolean NOT NULL DEFAULT true,
  achievement_enabled   boolean NOT NULL DEFAULT true,
  quiet_hours_start     int CHECK (quiet_hours_start BETWEEN 0 AND 23),  -- hour
  quiet_hours_end       int CHECK (quiet_hours_end   BETWEEN 0 AND 23),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "notif_prefs_self" ON notification_preferences
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- ============================================================
-- VIEW: daily review summary (used by notification scheduler)
-- ============================================================

CREATE OR REPLACE VIEW v_daily_review_due AS
SELECT
  p.id            AS user_id,
  p.timezone,
  p.notification_hour,
  COUNT(uvp.id)   AS cards_due,
  p.streak_days
FROM profiles p
JOIN user_vocabulary_progress uvp ON uvp.user_id = p.id
JOIN notification_preferences np  ON np.user_id  = p.id
WHERE uvp.due_date <= CURRENT_DATE
  AND np.review_due_enabled = true
GROUP BY p.id, p.timezone, p.notification_hour, p.streak_days;

-- ============================================================
-- STREAK MANAGEMENT FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION update_streak(p_user_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_last_date date;
  v_today     date := CURRENT_DATE;
BEGIN
  SELECT last_study_date INTO v_last_date
  FROM profiles WHERE id = p_user_id;

  IF v_last_date = v_today THEN
    -- Already counted today
    RETURN;
  ELSIF v_last_date = v_today - 1 THEN
    -- Consecutive day: extend streak
    UPDATE profiles
    SET streak_days = streak_days + 1,
        last_study_date = v_today
    WHERE id = p_user_id;
  ELSE
    -- Streak broken (or first day)
    UPDATE profiles
    SET streak_days = 1,
        last_study_date = v_today
    WHERE id = p_user_id;
  END IF;
END;
$$;

-- ============================================================
-- XP AWARD FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION award_xp(p_user_id uuid, p_xp int, p_reason text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE profiles
  SET total_xp = total_xp + p_xp
  WHERE id = p_user_id;
END;
$$;

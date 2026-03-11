-- ============================================================
-- French Learning App  ·  Database Schema  ·  Part 3: Grammar
-- ============================================================

-- ============================================================
-- GRAMMAR LESSONS
-- ============================================================

CREATE TABLE grammar_lessons (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title           text NOT NULL,
  slug            text UNIQUE NOT NULL,  -- e.g. "present-tense-er-verbs"
  description     text NOT NULL,
  cefr_level      cefr_level NOT NULL,
  topic_category  text NOT NULL,         -- 'tenses'|'pronouns'|'agreement'|etc.
  sort_order      int NOT NULL DEFAULT 0,
  -- Content
  explanation     text NOT NULL,         -- Markdown with HTML allowed
  explanation_examples jsonb NOT NULL DEFAULT '[]',
  -- [{"fr":"Je parle français.","en":"I speak French.","highlight":"parle"}]
  tips            text[],                -- quick bullet tips
  prerequisites   uuid[],                -- other grammar_lesson ids to complete first
  is_published    boolean NOT NULL DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_grammar_level  ON grammar_lessons(cefr_level, sort_order);
CREATE INDEX idx_grammar_slug   ON grammar_lessons(slug);

ALTER TABLE grammar_lessons ENABLE ROW LEVEL SECURITY;
CREATE POLICY "grammar_public_read" ON grammar_lessons FOR SELECT USING (is_published);

-- ============================================================
-- GRAMMAR EXERCISES
-- ============================================================

CREATE TABLE grammar_exercises (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id       uuid NOT NULL REFERENCES grammar_lessons(id) ON DELETE CASCADE,
  exercise_type   exercise_type NOT NULL,
  sort_order      int NOT NULL DEFAULT 0,
  prompt          text NOT NULL,         -- question or instruction
  prompt_audio_url text,
  -- For multiple_choice / matching
  options         jsonb,
  -- [{"id":"a","text":"parle"},{"id":"b","text":"parles"}]
  correct_answer  jsonb NOT NULL,
  -- multiple_choice: "a"
  -- fill_blank:      ["parle","avons"]   (ordered blanks)
  -- reorder:         ["Je","parle","français"]
  -- matching:        {"a":"1","b":"2"}
  explanation     text,                  -- why the answer is correct
  hint            text,
  xp_reward       int NOT NULL DEFAULT 5,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_exercises_lesson ON grammar_exercises(lesson_id, sort_order);

ALTER TABLE grammar_exercises ENABLE ROW LEVEL SECURITY;
CREATE POLICY "exercises_public_read" ON grammar_exercises FOR SELECT USING (true);

-- ============================================================
-- USER GRAMMAR PROGRESS
-- ============================================================

CREATE TABLE user_grammar_progress (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id       uuid NOT NULL REFERENCES grammar_lessons(id) ON DELETE CASCADE,
  is_started      boolean NOT NULL DEFAULT false,
  is_completed    boolean NOT NULL DEFAULT false,
  best_score_pct  int NOT NULL DEFAULT 0,
  attempts        int NOT NULL DEFAULT 0,
  last_attempt_at timestamptz,
  completed_at    timestamptz,
  xp_earned       int NOT NULL DEFAULT 0,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, lesson_id)
);

CREATE INDEX idx_ugp_user ON user_grammar_progress(user_id);

ALTER TABLE user_grammar_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ugp_self" ON user_grammar_progress
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- ============================================================
-- USER EXERCISE ATTEMPTS
-- ============================================================

CREATE TABLE user_exercise_attempts (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_id     uuid NOT NULL REFERENCES grammar_exercises(id) ON DELETE CASCADE,
  lesson_id       uuid NOT NULL REFERENCES grammar_lessons(id) ON DELETE CASCADE,
  user_answer     jsonb NOT NULL,
  is_correct      boolean NOT NULL,
  response_ms     int,
  attempted_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_attempts_user    ON user_exercise_attempts(user_id, attempted_at DESC);
CREATE INDEX idx_attempts_exercise ON user_exercise_attempts(exercise_id);

ALTER TABLE user_exercise_attempts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "attempts_self" ON user_exercise_attempts
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- ============================================================
-- TRIGGERS
-- ============================================================

CREATE TRIGGER trg_grammar_updated
  BEFORE UPDATE ON grammar_lessons FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_ugp_updated
  BEFORE UPDATE ON user_grammar_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- FUNCTION: update user level based on completed grammar lessons
-- ============================================================

CREATE OR REPLACE FUNCTION recalculate_user_level(p_user_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_completed_levels cefr_level[];
  v_new_level        cefr_level;
BEGIN
  -- Count completed lessons per CEFR level
  SELECT ARRAY_AGG(DISTINCT gl.cefr_level)
  INTO v_completed_levels
  FROM user_grammar_progress ugp
  JOIN grammar_lessons gl ON gl.id = ugp.lesson_id
  WHERE ugp.user_id = p_user_id
    AND ugp.is_completed = true;

  -- Simple heuristic: highest level where >= 80% lessons completed
  SELECT gl.cefr_level INTO v_new_level
  FROM grammar_lessons gl
  WHERE gl.cefr_level = ANY(v_completed_levels)
    AND gl.is_published = true
  GROUP BY gl.cefr_level
  HAVING (
    COUNT(*) FILTER (WHERE EXISTS (
      SELECT 1 FROM user_grammar_progress ugp
      WHERE ugp.lesson_id = gl.id AND ugp.user_id = p_user_id AND ugp.is_completed
    ))::numeric / COUNT(*) * 100
  ) >= 80
  ORDER BY gl.cefr_level DESC
  LIMIT 1;

  IF v_new_level IS NOT NULL THEN
    UPDATE profiles
    SET current_level = v_new_level
    WHERE id = p_user_id AND current_level < v_new_level;
  END IF;
END;
$$;

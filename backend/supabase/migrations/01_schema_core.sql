-- ============================================================
-- French Learning App  ·  Database Schema  ·  Part 1: Core
-- Target: Supabase (PostgreSQL 15+)
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";        -- fuzzy text search
CREATE EXTENSION IF NOT EXISTS "unaccent";        -- accent-insensitive search

-- ============================================================
-- ENUM TYPES
-- ============================================================

CREATE TYPE cefr_level      AS ENUM ('A1','A2','B1','B2','C1','C2');
CREATE TYPE word_class      AS ENUM (
  'noun','verb','adjective','adverb','preposition',
  'conjunction','pronoun','article','interjection','phrase'
);
CREATE TYPE gender_type     AS ENUM ('masculine','feminine','neuter','invariable');
CREATE TYPE exercise_type   AS ENUM (
  'multiple_choice','fill_blank','translation','reorder',
  'matching','listen_type','speak_record'
);
CREATE TYPE review_quality  AS ENUM ('again','hard','good','easy');   -- SM-2 grades 0-3
CREATE TYPE notification_type AS ENUM ('review_due','daily_article','streak_reminder','achievement');

-- ============================================================
-- PROFILES  (extends Supabase auth.users)
-- ============================================================

CREATE TABLE profiles (
  id                uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username          text UNIQUE NOT NULL,
  display_name      text,
  avatar_url        text,
  target_level      cefr_level NOT NULL DEFAULT 'A1',
  current_level     cefr_level NOT NULL DEFAULT 'A1',
  daily_goal_cards  int NOT NULL DEFAULT 20       CHECK (daily_goal_cards BETWEEN 5 AND 200),
  daily_goal_mins   int NOT NULL DEFAULT 15       CHECK (daily_goal_mins  BETWEEN 5 AND 120),
  timezone          text NOT NULL DEFAULT 'UTC',
  notification_hour int NOT NULL DEFAULT 8        CHECK (notification_hour BETWEEN 0 AND 23),
  streak_days       int NOT NULL DEFAULT 0,
  last_study_date   date,
  total_xp          int NOT NULL DEFAULT 0,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- VOCABULARY
-- ============================================================

CREATE TABLE vocabulary (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  french_word      text NOT NULL,
  english_trans    text NOT NULL,
  -- optional additional translations
  translations     jsonb NOT NULL DEFAULT '{}',   -- {"zh":"...", "es":"..."}
  word_class       word_class NOT NULL,
  gender           gender_type,                   -- for nouns/adjectives
  plural_form      text,
  conjugations     jsonb,                         -- verb conjugation table
  pronunciation_ipa text NOT NULL,               -- /pʁɔ̃.nɔ̃.sja.sjɔ̃/
  audio_url        text,                          -- Supabase Storage path
  cefr_level       cefr_level NOT NULL,
  topic_tags       text[] NOT NULL DEFAULT '{}', -- e.g. ['food','restaurant']
  frequency_rank   int,                           -- 1 = most common
  -- Rich content
  example_sentences jsonb NOT NULL DEFAULT '[]',
  -- [{"fr":"...","en":"...","audio_url":"..."}]
  usage_notes      text,
  memory_tip       text,                          -- mnemonic hint
  related_words    uuid[],                        -- other vocabulary ids
  is_active        boolean NOT NULL DEFAULT true,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT vocabulary_word_unique UNIQUE (french_word, word_class, cefr_level)
);

CREATE INDEX idx_vocabulary_level   ON vocabulary(cefr_level);
CREATE INDEX idx_vocabulary_class   ON vocabulary(word_class);
CREATE INDEX idx_vocabulary_tags    ON vocabulary USING gin(topic_tags);
CREATE INDEX idx_vocabulary_search  ON vocabulary USING gin(
  (to_tsvector('french', french_word) || to_tsvector('english', english_trans))
);
CREATE INDEX idx_vocabulary_freq    ON vocabulary(frequency_rank NULLS LAST);

-- ============================================================
-- USER VOCABULARY PROGRESS  (per-card SM-2 state)
-- ============================================================

CREATE TABLE user_vocabulary_progress (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  vocabulary_id   uuid NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  -- SM-2 fields
  repetitions     int NOT NULL DEFAULT 0,    -- n
  ease_factor     numeric(4,2) NOT NULL DEFAULT 2.50,  -- EF (≥1.3)
  interval_days   int NOT NULL DEFAULT 1,    -- I (days until next review)
  due_date        date NOT NULL DEFAULT CURRENT_DATE,
  -- Stats
  total_reviews   int NOT NULL DEFAULT 0,
  correct_reviews int NOT NULL DEFAULT 0,
  last_reviewed   timestamptz,
  -- Flags
  is_learned      boolean NOT NULL DEFAULT false,
  is_starred      boolean NOT NULL DEFAULT false,
  -- Metadata
  first_seen      timestamptz NOT NULL DEFAULT now(),
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT uvp_unique UNIQUE (user_id, vocabulary_id)
);

CREATE INDEX idx_uvp_user_due      ON user_vocabulary_progress(user_id, due_date);
CREATE INDEX idx_uvp_user_starred  ON user_vocabulary_progress(user_id, is_starred) WHERE is_starred;
CREATE INDEX idx_uvp_due_today     ON user_vocabulary_progress(due_date);

-- ============================================================
-- REVIEW SESSIONS
-- ============================================================

CREATE TABLE review_sessions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  started_at      timestamptz NOT NULL DEFAULT now(),
  ended_at        timestamptz,
  cards_reviewed  int NOT NULL DEFAULT 0,
  cards_correct   int NOT NULL DEFAULT 0,
  duration_secs   int,
  session_type    text NOT NULL DEFAULT 'scheduled'  -- 'scheduled'|'quick'|'mistake_review'
);

CREATE INDEX idx_sessions_user_date ON review_sessions(user_id, started_at DESC);

-- ============================================================
-- REVIEW EVENTS  (every individual card response)
-- ============================================================

CREATE TABLE review_events (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id      uuid NOT NULL REFERENCES review_sessions(id) ON DELETE CASCADE,
  user_id         uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  vocabulary_id   uuid NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  quality         review_quality NOT NULL,       -- again/hard/good/easy
  response_ms     int,                           -- time to answer in milliseconds
  -- SM-2 snapshot after this review
  new_interval    int NOT NULL,
  new_ease_factor numeric(4,2) NOT NULL,
  new_repetitions int NOT NULL,
  reviewed_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_events_user      ON review_events(user_id, reviewed_at DESC);
CREATE INDEX idx_events_vocab     ON review_events(vocabulary_id);
CREATE INDEX idx_events_session   ON review_events(session_id);

-- ============================================================
-- MISTAKE BOOK
-- ============================================================

CREATE TABLE mistake_book (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  vocabulary_id   uuid NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  -- Context where the mistake happened
  source_type     text NOT NULL,  -- 'flashcard'|'article'|'grammar_exercise'
  source_id       uuid,           -- session_id or article_id or exercise_id
  mistake_count   int NOT NULL DEFAULT 1,
  last_mistake_at timestamptz NOT NULL DEFAULT now(),
  is_resolved     boolean NOT NULL DEFAULT false,
  resolved_at     timestamptz,
  note            text,           -- user's own note
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT mistake_book_unique UNIQUE (user_id, vocabulary_id)
);

CREATE INDEX idx_mistake_user        ON mistake_book(user_id, last_mistake_at DESC);
CREATE INDEX idx_mistake_unresolved  ON mistake_book(user_id, is_resolved) WHERE NOT is_resolved;

-- ============================================================
-- ACHIEVEMENTS
-- ============================================================

CREATE TABLE achievements (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code        text UNIQUE NOT NULL,
  title       text NOT NULL,
  description text NOT NULL,
  icon_name   text NOT NULL,
  xp_reward   int NOT NULL DEFAULT 0,
  condition   jsonb NOT NULL  -- {"type":"streak","value":7}
);

CREATE TABLE user_achievements (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id uuid NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  earned_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, achievement_id)
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE profiles                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_vocabulary_progress  ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_sessions           ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_events             ENABLE ROW LEVEL SECURITY;
ALTER TABLE mistake_book              ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements         ENABLE ROW LEVEL SECURITY;

-- Profiles: users can only see/edit their own row
CREATE POLICY "profiles_self" ON profiles
  USING (id = auth.uid()) WITH CHECK (id = auth.uid());

-- User vocabulary progress: own rows only
CREATE POLICY "uvp_self" ON user_vocabulary_progress
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Review sessions: own rows only
CREATE POLICY "sessions_self" ON review_sessions
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Review events: own rows only
CREATE POLICY "events_self" ON review_events
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Mistake book: own rows only
CREATE POLICY "mistake_self" ON mistake_book
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- User achievements: own rows only
CREATE POLICY "achievements_self" ON user_achievements
  USING (user_id = auth.uid());

-- Vocabulary & achievements are public read
ALTER TABLE vocabulary    ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements  ENABLE ROW LEVEL SECURITY;
CREATE POLICY "vocab_public_read"  ON vocabulary   FOR SELECT USING (true);
CREATE POLICY "achiev_public_read" ON achievements FOR SELECT USING (true);

-- ============================================================
-- TRIGGERS: updated_at
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$;

CREATE TRIGGER trg_profiles_updated
  BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_uvp_updated
  BEFORE UPDATE ON user_vocabulary_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_mistake_updated
  BEFORE UPDATE ON mistake_book FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- TRIGGER: auto-create profile on signup
-- ============================================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO profiles (id, username, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email,'@',1)),
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email,'@',1))
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();

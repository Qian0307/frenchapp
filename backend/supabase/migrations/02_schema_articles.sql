-- ============================================================
-- French Learning App  ·  Database Schema  ·  Part 2: Articles
-- ============================================================

-- ============================================================
-- ARTICLES
-- ============================================================

CREATE TABLE articles (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title           text NOT NULL,
  subtitle        text,
  cover_image_url text,
  body_raw        text NOT NULL,   -- original French text (plain)
  body_annotated  jsonb NOT NULL,  -- tokenised with vocab links (see below)
  -- body_annotated structure:
  -- [
  --   { "type": "paragraph", "tokens": [
  --       { "text": "Bonjour", "vocab_id": "uuid|null", "is_clickable": true },
  --       { "text": " ", "vocab_id": null, "is_clickable": false }
  --   ]},
  --   { "type": "heading", "tokens": [...] }
  -- ]
  audio_url       text,            -- full article audio narration
  cefr_level      cefr_level NOT NULL,
  topic_tags      text[] NOT NULL DEFAULT '{}',
  word_count      int,
  reading_time_mins int,
  is_published    boolean NOT NULL DEFAULT false,
  published_date  date,
  author          text NOT NULL DEFAULT 'Editorial Team',
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_articles_level     ON articles(cefr_level);
CREATE INDEX idx_articles_published ON articles(published_date DESC) WHERE is_published;
CREATE INDEX idx_articles_tags      ON articles USING gin(topic_tags);

ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "articles_public_read" ON articles FOR SELECT USING (is_published);

-- ============================================================
-- ARTICLE VOCABULARY LINKS
-- (denormalised fast lookup: which vocab appears in which article)
-- ============================================================

CREATE TABLE article_vocabulary (
  article_id    uuid NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  vocabulary_id uuid NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  occurrences   int NOT NULL DEFAULT 1,
  PRIMARY KEY (article_id, vocabulary_id)
);

CREATE INDEX idx_artvocab_article ON article_vocabulary(article_id);
CREATE INDEX idx_artvocab_vocab   ON article_vocabulary(vocabulary_id);

ALTER TABLE article_vocabulary ENABLE ROW LEVEL SECURITY;
CREATE POLICY "artvocab_public_read" ON article_vocabulary FOR SELECT USING (true);

-- ============================================================
-- USER ARTICLE READS
-- ============================================================

CREATE TABLE user_article_reads (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  article_id     uuid NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  progress_pct   int NOT NULL DEFAULT 0  CHECK (progress_pct BETWEEN 0 AND 100),
  is_completed   boolean NOT NULL DEFAULT false,
  started_at     timestamptz NOT NULL DEFAULT now(),
  completed_at   timestamptz,
  time_spent_secs int NOT NULL DEFAULT 0,
  words_looked_up int NOT NULL DEFAULT 0,  -- tapped vocab count
  UNIQUE (user_id, article_id)
);

CREATE INDEX idx_article_reads_user ON user_article_reads(user_id, started_at DESC);

ALTER TABLE user_article_reads ENABLE ROW LEVEL SECURITY;
CREATE POLICY "article_reads_self" ON user_article_reads
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- ============================================================
-- DAILY ARTICLE SCHEDULE
-- ============================================================

CREATE TABLE daily_articles (
  schedule_date  date NOT NULL,
  cefr_level     cefr_level NOT NULL,
  article_id     uuid NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  PRIMARY KEY (schedule_date, cefr_level)
);

ALTER TABLE daily_articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "daily_articles_public_read" ON daily_articles FOR SELECT USING (true);

-- ============================================================
-- TRIGGERS
-- ============================================================

CREATE TRIGGER trg_articles_updated
  BEFORE UPDATE ON articles FOR EACH ROW EXECUTE FUNCTION update_updated_at();

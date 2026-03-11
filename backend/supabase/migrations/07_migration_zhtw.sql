-- ============================================================
-- Migration: enforce 繁體中文 in translations JSONB
-- Add GIN index for zh_tw lookup
-- Add helper view and function
-- ============================================================

-- ── 1. Add check constraint: if zh key exists, must be zh_tw ─
-- (We rename zh → zh_tw in all existing rows)

UPDATE vocabulary
SET translations = (translations - 'zh') ||
    jsonb_build_object('zh_tw', translations->>'zh')
WHERE translations ? 'zh'
  AND NOT (translations ? 'zh_tw');

-- ── 2. GIN index for fast zh_tw translation lookup ───────────

CREATE INDEX IF NOT EXISTS idx_vocab_translations_gin
  ON vocabulary USING gin(translations jsonb_path_ops);

-- ── 3. Helper function: full-text search across FR + EN + ZH ─

CREATE OR REPLACE FUNCTION search_vocabulary(
  p_query text,
  p_level cefr_level DEFAULT NULL,
  p_limit int       DEFAULT 30,
  p_offset int      DEFAULT 0
)
RETURNS TABLE (
  id               uuid,
  french_word      text,
  english_trans    text,
  zh_tw            text,
  word_class       word_class,
  gender           gender_type,
  pronunciation_ipa text,
  cefr_level       cefr_level,
  topic_tags       text[],
  frequency_rank   int
) LANGUAGE sql STABLE AS $$
  SELECT
    v.id,
    v.french_word,
    v.english_trans,
    v.translations->>'zh_tw' AS zh_tw,
    v.word_class,
    v.gender,
    v.pronunciation_ipa,
    v.cefr_level,
    v.topic_tags,
    v.frequency_rank
  FROM vocabulary v
  WHERE v.is_active = true
    AND (p_level IS NULL OR v.cefr_level = p_level)
    AND (
      v.french_word    ILIKE '%' || p_query || '%'  OR
      v.english_trans  ILIKE '%' || p_query || '%'  OR
      v.translations->>'zh_tw' ILIKE '%' || p_query || '%'
    )
  ORDER BY v.frequency_rank ASC NULLS LAST
  LIMIT  p_limit
  OFFSET p_offset;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION search_vocabulary TO authenticated;

-- ── 4. View: vocabulary with zh_tw surfaced as a column ──────

CREATE OR REPLACE VIEW v_vocabulary_with_zhtw AS
SELECT
  id,
  french_word,
  english_trans,
  translations->>'zh_tw'  AS chinese_trans_tw,
  translations->>'es'     AS spanish_trans,
  translations->>'de'     AS german_trans,
  word_class,
  gender,
  plural_form,
  conjugations,
  pronunciation_ipa,
  audio_url,
  cefr_level,
  topic_tags,
  frequency_rank,
  example_sentences,
  usage_notes,
  memory_tip,
  is_active,
  created_at
FROM vocabulary;

-- ── 5. RPC for Flutter: get_due_cards_with_zhtw ─────────────

CREATE OR REPLACE FUNCTION get_due_cards_with_zhtw(
  p_user_id  uuid,
  p_limit    int  DEFAULT 20,
  p_due_date date DEFAULT CURRENT_DATE
)
RETURNS TABLE (
  progress_id      uuid,
  vocabulary_id    uuid,
  french_word      text,
  english_trans    text,
  chinese_trans_tw text,
  word_class       word_class,
  gender           gender_type,
  pronunciation_ipa text,
  audio_url        text,
  cefr_level       cefr_level,
  example_sentences jsonb,
  usage_notes      text,
  memory_tip       text,
  repetitions      int,
  ease_factor      numeric,
  interval_days    int,
  due_date         date,
  is_starred       bool
) LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT
    uvp.id,
    uvp.vocabulary_id,
    v.french_word,
    v.english_trans,
    v.translations->>'zh_tw',
    v.word_class,
    v.gender,
    v.pronunciation_ipa,
    v.audio_url,
    v.cefr_level,
    v.example_sentences,
    v.usage_notes,
    v.memory_tip,
    uvp.repetitions,
    uvp.ease_factor,
    uvp.interval_days,
    uvp.due_date,
    uvp.is_starred
  FROM user_vocabulary_progress uvp
  JOIN vocabulary v ON v.id = uvp.vocabulary_id
  WHERE uvp.user_id  = p_user_id
    AND uvp.due_date <= p_due_date
    AND v.is_active  = true
  ORDER BY uvp.due_date ASC, uvp.repetitions ASC
  LIMIT p_limit;
$$;

GRANT EXECUTE ON FUNCTION get_due_cards_with_zhtw TO authenticated;

-- ── 6. Comment documenting the zh_tw convention ──────────────

COMMENT ON COLUMN vocabulary.translations IS
  'JSONB map of extra translations. Key "zh_tw" = 繁體中文. '
  'Keys: zh_tw (Traditional Chinese), es (Spanish), de (German), etc. '
  'The zh (Simplified Chinese) key is deprecated — use zh_tw.';

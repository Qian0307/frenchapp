-- ============================================================
-- French Learning App  ·  Seed Data: Achievements + Sample Vocab
-- ============================================================

-- ============================================================
-- ACHIEVEMENTS
-- ============================================================

INSERT INTO achievements (code, title, description, icon_name, xp_reward, condition) VALUES
('first_card',     'Premier Mot',       'Review your first flashcard',          'star_outline',    10,  '{"type":"total_reviews","value":1}'),
('streak_3',       'En Route',          '3-day study streak',                   'local_fire_dept', 30,  '{"type":"streak","value":3}'),
('streak_7',       'Une Semaine',       '7-day study streak',                   'whatshot',        75,  '{"type":"streak","value":7}'),
('streak_30',      'Un Mois',           '30-day study streak',                  'emoji_events',    300, '{"type":"streak","value":30}'),
('cards_100',      'Cent Mots',         'Review 100 flashcards total',          'style',           50,  '{"type":"total_reviews","value":100}'),
('cards_500',      'Vocabulaire Riche', 'Review 500 flashcards total',          'military_tech',   200, '{"type":"total_reviews","value":500}'),
('cards_1000',     'Érudit',            'Review 1000 flashcards total',         'workspace_premium',500,'{"type":"total_reviews","value":1000}'),
('first_article',  'Premier Lecteur',   'Read your first article',              'menu_book',       20,  '{"type":"articles_read","value":1}'),
('articles_10',    'Grand Lecteur',     'Read 10 articles',                     'auto_stories',    100, '{"type":"articles_read","value":10}'),
('grammar_a1',     'Bases Solides',     'Complete all A1 grammar lessons',      'school',          50,  '{"type":"grammar_level","value":"A1"}'),
('grammar_b1',     'Intermédiaire',     'Complete all B1 grammar lessons',      'grade',           150, '{"type":"grammar_level","value":"B1"}'),
('perfect_day',    'Perfection',        'Score 100% in a review session',       'done_all',        50,  '{"type":"perfect_session","value":1}'),
('mistake_cleared','Leçon Apprise',     'Resolve 10 mistakes from your book',   'check_circle',    40,  '{"type":"mistakes_resolved","value":10}');

-- ============================================================
-- GRAMMAR LESSONS (A1)
-- ============================================================

INSERT INTO grammar_lessons (title, slug, description, cefr_level, topic_category, sort_order, explanation, explanation_examples, tips, is_published) VALUES

('Present Tense: -er Verbs',
 'present-er-verbs', 'Learn to conjugate regular -er verbs in the present tense.',
 'A1', 'tenses', 1,
 '## Present Tense: -ER Verbs

Regular **-er** verbs follow a predictable pattern. Remove the **-er** ending and add the appropriate suffix.

| Pronoun | Suffix | Example (parler) |
|---------|--------|-----------------|
| je      | -e     | parle           |
| tu      | -es    | parles          |
| il/elle | -e     | parle           |
| nous    | -ons   | parlons         |
| vous    | -ez    | parlez          |
| ils/elles | -ent | parlent         |',
 '[
   {"fr":"Je parle français.","en":"I speak French.","highlight":"parle"},
   {"fr":"Elle mange une pomme.","en":"She eats an apple.","highlight":"mange"},
   {"fr":"Nous regardons la télé.","en":"We watch TV.","highlight":"regardons"}
 ]',
 ARRAY['je/il/elle share the same spoken form for most -er verbs','The -ent ending is silent','Common -er verbs: parler, manger, habiter, travailler, écouter'],
 true),

('Articles: Definite and Indefinite',
 'french-articles', 'Master le, la, les, un, une, des.',
 'A1', 'articles', 2,
 '## French Articles

**Definite articles** (the): **le** (m), **la** (f), **l''** (before vowel), **les** (plural)
**Indefinite articles** (a/an): **un** (m), **une** (f), **des** (plural)

Use definite when the noun is specific or known. Use indefinite for unspecified items.',
 '[
   {"fr":"Le chat est mignon.","en":"The cat is cute.","highlight":"Le"},
   {"fr":"J''ai un chien.","en":"I have a dog.","highlight":"un"},
   {"fr":"Des pommes, s''il vous plaît.","en":"Some apples, please.","highlight":"Des"}
 ]',
 ARRAY['l'' is used before any noun starting with a vowel or silent h','des becomes de after negation: pas de pommes'],
 true),

('Negation: ne...pas',
 'negation-ne-pas', 'Learn to make sentences negative.',
 'A1', 'syntax', 3,
 '## Negation: ne...pas

Surround the conjugated verb with **ne** ... **pas**.

In spoken French, **ne** is often dropped: *Je sais pas.*
In writing, always keep both parts.',
 '[
   {"fr":"Je ne parle pas espagnol.","en":"I do not speak Spanish.","highlight":"ne...pas"},
   {"fr":"Elle n''aime pas le café.","en":"She does not like coffee.","highlight":"n''...pas"},
   {"fr":"Nous ne sommes pas fatigués.","en":"We are not tired.","highlight":"ne...pas"}
 ]',
 ARRAY['ne becomes n'' before a vowel or h','Indefinite articles change: un/une/des → de/d'' after negation'],
 true);

-- ============================================================
-- GRAMMAR EXERCISES (for first lesson)
-- ============================================================

INSERT INTO grammar_exercises (lesson_id, exercise_type, sort_order, prompt, options, correct_answer, explanation, hint, xp_reward)
SELECT
  gl.id,
  'multiple_choice',
  1,
  'Choose the correct form of "parler" for "nous":',
  '[{"id":"a","text":"parle"},{"id":"b","text":"parlons"},{"id":"c","text":"parlez"},{"id":"d","text":"parlent"}]',
  '"b"',
  'For nous, regular -er verbs take the -ons ending: nous parlons.',
  'Nous needs -ons',
  5
FROM grammar_lessons gl WHERE gl.slug = 'present-er-verbs';

INSERT INTO grammar_exercises (lesson_id, exercise_type, sort_order, prompt, correct_answer, explanation, hint, xp_reward)
SELECT
  gl.id,
  'fill_blank',
  2,
  'Fill in the blank: "Tu ___ (habiter) à Paris."',
  '"habites"',
  'Tu takes the -es ending: tu habites.',
  'Remove -er, add -es',
  5
FROM grammar_lessons gl WHERE gl.slug = 'present-er-verbs';

INSERT INTO grammar_exercises (lesson_id, exercise_type, sort_order, prompt, options, correct_answer, explanation, hint, xp_reward)
SELECT
  gl.id,
  'multiple_choice',
  3,
  'Which article is correct? "___ livre est intéressant." (The book is interesting.)',
  '[{"id":"a","text":"Un"},{"id":"b","text":"Le"},{"id":"c","text":"La"},{"id":"d","text":"Les"}]',
  '"b"',
  '"Livre" is masculine, so the definite article is "le".',
  'Livre is masculine (le livre)',
  5
FROM grammar_lessons gl WHERE gl.slug = 'french-articles';

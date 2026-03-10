class AppConstants {
  AppConstants._();

  // ── Supabase ─────────────────────────────────────────────
  static const supabaseUrl     = String.fromEnvironment('SUPABASE_URL',
      defaultValue: 'https://YOUR_PROJECT.supabase.co');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY',
      defaultValue: 'YOUR_ANON_KEY');

  // ── Edge Function base paths ──────────────────────────────
  static const fnFlashcards    = 'flashcards';
  static const fnArticles      = 'articles';
  static const fnGrammar       = 'grammar';
  static const fnMistakeBook   = 'mistake-book';
  static const fnNotifications = 'notifications';

  // ── CEFR levels (ordered) ─────────────────────────────────
  static const cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  // ── Review session defaults ───────────────────────────────
  static const defaultDailyGoalCards = 20;
  static const newCardsPerSession     = 5;   // max new cards per session
  static const maxCardsPerSession     = 50;

  // ── SM-2 constants ────────────────────────────────────────
  static const defaultEaseFactor = 2.5;
  static const minEaseFactor     = 1.3;
  static const maxInterval       = 365;  // days

  // ── XP rewards ───────────────────────────────────────────
  static const xpPerCorrectCard  = 2;
  static const xpPerWrongCard    = 1;
  static const xpArticleComplete = 20;
  static const xpExerciseCorrect = 5;

  // ── Hive box names ────────────────────────────────────────
  static const hiveVocabCache   = 'vocab_cache';
  static const hiveArticleCache = 'article_cache';

  // ── Animation durations ───────────────────────────────────
  static const cardFlipDuration   = Duration(milliseconds: 400);
  static const pageTransDuration  = Duration(milliseconds: 280);
  static const snackbarDuration   = Duration(seconds: 3);
}

class AppConstants {
  AppConstants._();

  // ── Supabase ─────────────────────────────────────────────
  static const supabaseUrl     = String.fromEnvironment('SUPABASE_URL',
      defaultValue: 'https://xvjmhsuvrakjporptoyw.supabase.co');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2am1oc3V2cmFranBvcnB0b3l3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMxMDc1MTksImV4cCI6MjA4ODY4MzUxOX0.ntzvRSiGuZB2gyYACrJw5SLaZUTt_QqV1-btq3Be3Qc');

  /// Call this early in main() before Supabase.initialize().
  /// Throws [StateError] if credentials are still placeholders.
  static void validateCredentials() {
    if (supabaseUrl == 'https://YOUR_PROJECT.supabase.co') {
      throw StateError(
        'SUPABASE_URL is not set. '
        'Run with --dart-define=SUPABASE_URL=https://xxxx.supabase.co',
      );
    }
    if (supabaseAnonKey == 'YOUR_ANON_KEY') {
      throw StateError(
        'SUPABASE_ANON_KEY is not set. '
        'Run with --dart-define=SUPABASE_ANON_KEY=your-anon-key',
      );
    }
  }

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

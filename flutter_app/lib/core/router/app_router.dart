import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/flashcards/presentation/pages/flashcard_session_page.dart';
import '../../features/flashcards/presentation/pages/vocabulary_browser_page.dart';
import '../../features/articles/presentation/pages/article_list_page.dart';
import '../../features/articles/presentation/pages/article_reader_page.dart';
import '../../features/grammar/presentation/pages/grammar_list_page.dart';
import '../../features/grammar/presentation/pages/grammar_lesson_page.dart';
import '../../features/mistake_book/presentation/pages/mistake_book_page.dart';
import '../shell/main_shell.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth  = session != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuth && !isAuthRoute) return '/auth/login';
      if (isAuth  &&  isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────
      GoRoute(path: '/auth/login',    builder: (_, __) => const LoginPage()),
      GoRoute(path: '/auth/register', builder: (_, __) => const RegisterPage()),

      // ── Main shell (bottom nav) ───────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardPage(),
          ),

          // Flashcards
          GoRoute(
            path: '/flashcards',
            builder: (_, __) => const VocabularyBrowserPage(),
            routes: [
              GoRoute(
                path: 'session',
                builder: (_, state) {
                  final type = state.uri.queryParameters['type'] ?? 'scheduled';
                  return FlashcardSessionPage(sessionType: type);
                },
              ),
            ],
          ),

          // Articles
          GoRoute(
            path: '/articles',
            builder: (_, __) => const ArticleListPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    ArticleReaderPage(articleId: state.pathParameters['id']!),
              ),
            ],
          ),

          // Grammar
          GoRoute(
            path: '/grammar',
            builder: (_, __) => const GrammarListPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    GrammarLessonPage(lessonId: state.pathParameters['id']!),
              ),
            ],
          ),

          // Mistake book
          GoRoute(
            path: '/mistakes',
            builder: (_, __) => const MistakeBookPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
}

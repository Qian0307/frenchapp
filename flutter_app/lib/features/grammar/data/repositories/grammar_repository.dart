import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/grammar_model.dart';

part 'grammar_repository.g.dart';

@riverpod
GrammarRepository grammarRepository(GrammarRepositoryRef ref) =>
    GrammarRepository(Supabase.instance.client);

class GrammarRepository {
  GrammarRepository(this._supabase);
  final SupabaseClient _supabase;

  /// Lists grammar lessons directly from the database.
  /// Uses a direct Supabase query instead of an edge function to avoid
  /// Flutter Web Authorization header issues.
  Future<List<GrammarLesson>> listLessons({String? level}) async {
    final userId = _supabase.auth.currentUser?.id;

    // Fetch lessons; if user is logged in, also fetch their progress
    var q = _supabase
        .from('grammar_lessons')
        .select('id, title, description, cefr_level, topic_category, sort_order')
        .eq('is_published', true);

    if (level != null) {
      q = q.eq('cefr_level', level);
    }

    final rows = await q.order('sort_order', ascending: true);

    if (userId == null || (rows as List).isEmpty) {
      return (rows as List)
          .map((e) => GrammarLesson.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Fetch progress for all lessons in one query
    final lessonIds = (rows as List).map((r) => r['id'] as String).toList();
    final progressRows = await _supabase
        .from('user_grammar_progress')
        .select('lesson_id, is_completed, is_started, best_score_pct')
        .eq('user_id', userId)
        .inFilter('lesson_id', lessonIds);

    // Build a map for quick lookup
    final progressMap = <String, Map<String, dynamic>>{};
    for (final p in progressRows as List) {
      progressMap[p['lesson_id'] as String] = p as Map<String, dynamic>;
    }

    // Merge progress into each lesson row so GrammarLesson.fromJson works
    return (rows as List).map((e) {
      final lessonMap = Map<String, dynamic>.from(e as Map<String, dynamic>);
      final progress = progressMap[lessonMap['id'] as String];
      if (progress != null) {
        lessonMap['progress'] = {
          'is_completed':  progress['is_completed'],
          'is_started':    progress['is_started'],
          'best_score_pct': progress['best_score_pct'],
        };
      }
      return GrammarLesson.fromJson(lessonMap);
    }).toList();
  }

  /// Fetches a single lesson detail via edge function (marks lesson as started).
  Future<Map<String, dynamic>> getLesson(String id) async {
    final res = await _supabase.functions.invoke(
      'grammar/lessons/$id',
      method: HttpMethod.get,
      headers: _authHeaders,
    );
    _checkError(res);
    return (res.data as Map)['lesson'] as Map<String, dynamic>;
  }

  Future<void> completeLesson(String id, {required int scorePct}) async {
    final res = await _supabase.functions.invoke(
      'grammar/lessons/$id/complete',
      body: {'score_pct': scorePct},
      method: HttpMethod.post,
      headers: _authHeaders,
    );
    _checkError(res);
  }


  Map<String, String>? get _authHeaders {
    final token = _supabase.auth.currentSession?.accessToken;
    return token != null ? {'Authorization': 'Bearer $token'} : null;
  }

  void _checkError(FunctionResponse res) {
    if (res.data is Map && (res.data as Map).containsKey('error')) {
      throw Exception((res.data as Map)['error']);
    }
  }
}

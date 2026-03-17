import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/article_model.dart';

part 'article_repository.g.dart';

@riverpod
ArticleRepository articleRepository(ArticleRepositoryRef ref) =>
    ArticleRepository(Supabase.instance.client);

class ArticleRepository {
  ArticleRepository(this._supabase);
  final SupabaseClient _supabase;

  /// Lists articles directly from the database.
  /// Uses a direct Supabase query instead of an edge function to avoid
  /// Flutter Web Authorization header issues.
  Future<List<ArticleModel>> listArticles({String? level, int page = 1}) async {
    const limit = 20;
    final offset = (page - 1) * limit;
    final userId = _supabase.auth.currentUser?.id;

    var q = _supabase
        .from('articles')
        .select('id, title, subtitle, cefr_level, reading_time_mins, topic_tags, cover_image_url')
        .eq('is_published', true);

    if (level != null) {
      q = q.eq('cefr_level', level);
    }

    final rows = await q
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);

    if (userId == null || (rows as List).isEmpty) {
      return (rows as List)
          .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Fetch read progress for all articles in one query
    final articleIds = (rows as List).map((r) => r['id'] as String).toList();
    final progressRows = await _supabase
        .from('user_article_progress')
        .select('article_id, progress_pct, is_completed')
        .eq('user_id', userId)
        .inFilter('article_id', articleIds);

    // Build a map for quick lookup
    final progressMap = <String, Map<String, dynamic>>{};
    for (final p in progressRows as List) {
      progressMap[p['article_id'] as String] = p as Map<String, dynamic>;
    }

    // Merge progress into each article row so ArticleModel.fromJson works
    return (rows as List).map((e) {
      final articleMap = Map<String, dynamic>.from(e as Map<String, dynamic>);
      final progress = progressMap[articleMap['id'] as String];
      if (progress != null) {
        articleMap['read_progress'] = {
          'progress_pct': progress['progress_pct'],
          'is_completed': progress['is_completed'],
        };
      }
      return ArticleModel.fromJson(articleMap);
    }).toList();
  }

  Future<void> startArticle(String id) async {
    final res = await _supabase.functions.invoke(
      'articles/$id/start',
      method: HttpMethod.post,
      body: {},
    );
    _checkError(res);
  }

  /// Fetches a single article's full content via edge function.
  Future<Map<String, dynamic>> getArticle(String id) async {
    final res = await _supabase.functions.invoke(
      'articles/$id',
      method: HttpMethod.get,
      headers: _authHeaders,
    );
    _checkError(res);
    return (res.data as Map)['article'] as Map<String, dynamic>;
  }

  Future<void> updateProgress(String id, int progressPct) async {
    final res = await _supabase.functions.invoke(
      'articles/$id/progress',
      body: {'progress_pct': progressPct},
      method: HttpMethod.post,
      headers: _authHeaders,
    );
    _checkError(res);
  }

  Future<Map<String, dynamic>> lookupVocab(String vocabId) async {
    final res = await _supabase.functions.invoke(
      'articles/vocab/$vocabId',
      method: HttpMethod.get,
      headers: _authHeaders,
    );
    _checkError(res);
    return (res.data as Map)['vocabulary'] as Map<String, dynamic>;
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

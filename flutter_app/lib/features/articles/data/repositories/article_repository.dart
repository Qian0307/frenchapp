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

  Future<List<ArticleModel>> listArticles({String? level, int page = 1}) async {
    final params = <String, String>{'page': page.toString()};
    if (level != null) params['level'] = level;
    final qs = params.entries.map((e) => '${e.key}=${e.value}').join('&');

    final res = await _supabase.functions.invoke(
      'articles/list?$qs',
      method: HttpMethod.get,
    );
    _checkError(res);
    final list = (res.data as Map)['articles'] as List;
    return list
        .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> startArticle(String id) async {
    final res = await _supabase.functions.invoke(
      'articles/$id/start',
      method: HttpMethod.post,
      body: {},
    );
    _checkError(res);
  }

  Future<Map<String, dynamic>> getArticle(String id) async {
    final res = await _supabase.functions.invoke(
      'articles/$id',
      method: HttpMethod.get,
    );
    _checkError(res);
    return (res.data as Map)['article'] as Map<String, dynamic>;
  }

  Future<void> updateProgress(String id, int progressPct) async {
    final res = await _supabase.functions.invoke(
      'articles/$id/progress',
      body: {'progress_pct': progressPct},
      method: HttpMethod.post,
    );
    _checkError(res);
  }

  Future<Map<String, dynamic>> lookupVocab(String vocabId) async {
    final res = await _supabase.functions.invoke(
      'articles/vocab/$vocabId',
      method: HttpMethod.get,
    );
    _checkError(res);
    return (res.data as Map)['vocabulary'] as Map<String, dynamic>;
  }

  void _checkError(FunctionResponse res) {
    if (res.data is Map && (res.data as Map).containsKey('error')) {
      throw Exception((res.data as Map)['error']);
    }
  }
}

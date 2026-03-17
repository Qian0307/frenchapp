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

  Future<List<GrammarLesson>> listLessons({String? level}) async {
    final qs = level != null ? 'level=$level' : '';
    final res = await _supabase.functions.invoke(
      'grammar/lessons${qs.isNotEmpty ? '?$qs' : ''}',
      method: HttpMethod.get,
    );
    _checkError(res);
    final list = (res.data as Map)['lessons'] as List;
    return list
        .map((e) => GrammarLesson.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getLesson(String id) async {
    final res = await _supabase.functions.invoke(
      'grammar/lessons/$id',
      method: HttpMethod.get,
    );
    _checkError(res);
    return (res.data as Map)['lesson'] as Map<String, dynamic>;
  }

  Future<void> completeLesson(String id, {required int scorePct}) async {
    final res = await _supabase.functions.invoke(
      'grammar/lessons/$id/complete',
      body: {'score_pct': scorePct},
      method: HttpMethod.post,
    );
    _checkError(res);
  }

  void _checkError(FunctionResponse res) {
    if (res.data is Map && (res.data as Map).containsKey('error')) {
      throw Exception((res.data as Map)['error']);
    }
  }
}

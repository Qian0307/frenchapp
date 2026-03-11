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

  void _checkError(FunctionResponse res) {
    if (res.data is Map && (res.data as Map).containsKey('error')) {
      throw Exception((res.data as Map)['error']);
    }
  }
}
